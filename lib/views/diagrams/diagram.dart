import 'package:concept_designer/common/globals.dart';
import 'package:concept_designer/common/misc.dart';
import 'package:concept_designer/views/blocks/block.dart';
import 'package:concept_designer/views/links/link.dart';
import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';

part 'diagram.g.dart';

class DiagramView extends ConsumerStatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  DiagramView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DiagramViewState();
}

class _DiagramViewState extends ConsumerState<DiagramView> {
  late MyPolicySet _myPolicySet;

  @override
  void initState() {
    super.initState();
    _myPolicySet = MyPolicySet(ref);
    _myPolicySet.selections = ref.read(Globals.selectionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(Globals.selectionsProvider, (_, next) {
      _myPolicySet.selections = next;
    });
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.orange.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: GridPaper(
        color: Globals.myTheme.colorScheme.onBackground.withOpacity(0.2),
        child: DiagramEditor(
          key: UniqueKey(),
          diagramEditorContext: DiagramEditorContext(
            policySet: _myPolicySet,
          ),
        ),
      ),
    );
  }
}

// Custom component Data which you can assign to a component to dynamic data property.
@JsonSerializable()
class ComponentViewData {
  ComponentViewData({
    required this.block,
  });

  bool isHighlightVisible = false;
  final Block block;

  showHighlight() {
    isHighlightVisible = true;
  }

  hideHighlight() {
    isHighlightVisible = false;
  }

  // Function used to deserialize the diagram. Must be passed to `canvasWriter.model.deserializeDiagram` for proper deserialization.
  factory ComponentViewData.fromJson(Map<String, dynamic> json) => _$ComponentViewDataFromJson(json);

  // Function used to serialization of the diagram. E.g. to save to a file.
  Map<String, dynamic> toJson() => _$ComponentViewDataToJson(this);
}

// A set of policies compound of mixins. There are some custom policy implementations and some policies defined by diagram_editor library.
class MyPolicySet extends PolicySet
    with
        // A place where you can init the canvas or your diagram (eg. load an existing diagram).
        InitPolicy,

        // This is the place where you can design a component.
        // Use switch on componentData.type or componentData.data to define different component designs.
        ComponentDesignPolicy,

        // You can override the behavior of any gesture on canvas here.
        // Note that it also implements CustomPolicy where own variables and functions can be defined and used here.
        CanvasPolicy,

        // Where component behaviour is defined. In this example it is the movement, highlight and connecting two components.
        ComponentPolicy,

        //
        CanvasControlPolicy,
        LinkControlPolicy,
        LinkJointControlPolicy,
        LinkAttachmentRectPolicy {
  MyPolicySet(this.ref);

  late Selections selections;
  WidgetRef ref;
  String? selectedComponentId;

  // variable used to calculate delta offset to move the component.
  late Offset lastFocalPoint;

  @override
  initializeDiagramEditor() {
    canvasWriter.state.setCanvasColor(_DiagramColors.canvas);
    _loadFromDb();
  }

  _loadFromDb() {
    Globals.componentsBox.getAll(Globals.componentsBox.keys).forEach((e) => canvasWriter.model.addComponent(e!));
    Globals.linksBox.getAll(Globals.linksBox.keys).forEach((e) => canvasReader.model.canvasModel.addLink(e!));
  }

  @override
  void disposeAnimationController() {
    // super call of this disposes of the _animation controller when it is still in use
    // which results in an error when trying to pan after a setState of the main Scaffold body
  }

  @override
  Widget showComponentBody(ComponentData componentData) {
    final data = (componentData.data as ComponentViewData);
    return Card(
      elevation: 4.0,
      color: data.isHighlightVisible ? _DiagramColors.componentSelected : _DiagramColors.component,
      child: Center(child: Text(data.block.name)),
    );
  }

  @override
  onCanvasTapUp(TapUpDetails details) {
    canvasWriter.model.hideAllLinkJoints();
    if (selectedComponentId != null) {
      _hideComponentHighlight(selectedComponentId);
    } else {
      final selectedBlock = selections.block;
      if (selectedBlock != null) {
        // Add component to canvas.
        final componentId = canvasWriter.model.addComponent(
          ComponentData(
            size: const Size(96, 72),
            position: canvasReader.state.fromCanvasCoordinates(details.localPosition),
            data: ComponentViewData(block: selectedBlock),
          ),
        );

        // Retrieve created component
        final component = canvasReader.model.getComponent(componentId);

        // Add component to database.
        Globals.componentsBox.put(componentId, component);

        // Update selections to notify it is no longer selected/highlighted.
        ref.read(Globals.selectionsProvider.notifier).updateBlock(null);
      } else {}
    }
  }

  @override
  onLinkTap(String linkId) {
    final link = canvasReader.model.getLink(linkId);

    final isSelected = link.linkStyle.color == _DiagramColors.linkSelected;
    if (isSelected) {
      // It is already selected and tapped to deselect it
      link.linkStyle.lineWidth = 2;
      link.linkStyle.color = _DiagramColors.link;
      ref.read(Globals.selectionsProvider.notifier).updateLink(null);
    } else {
      // It is tapped to get selected
      link.linkStyle.lineWidth = 3;
      link.linkStyle.color = _DiagramColors.linkSelected;

      ref.read(Globals.selectionsProvider.notifier).updateLink(link);
    }
    canvasWriter.model.updateLink(linkId);
  }

  @override
  onComponentTap(String componentId) {
    canvasWriter.model.hideAllLinkJoints();

    bool connected = connectComponents(selectedComponentId, componentId);
    _hideComponentHighlight(selectedComponentId);
    if (!connected) {
      _highlightComponent(componentId);
    }
  }

  @override
  onComponentLongPress(String componentId) {
    _hideComponentHighlight(selectedComponentId);
    canvasWriter.model.hideAllLinkJoints();
    canvasWriter.model.removeComponent(componentId);
  }

  @override
  onComponentScaleStart(componentId, details) {
    lastFocalPoint = details.localFocalPoint;
  }

  @override
  onComponentScaleUpdate(componentId, details) {
    Offset positionDelta = details.localFocalPoint - lastFocalPoint;
    canvasWriter.model.moveComponent(componentId, positionDelta);
    lastFocalPoint = details.localFocalPoint;

    final updatedComponent = canvasReader.model.getComponent(componentId);
    Globals.componentsBox.put(componentId, updatedComponent);
  }

  // This function tests if it's possible to connect the components and if yes, connects them
  bool connectComponents(String? sourceComponentId, String? targetComponentId) {
    if (sourceComponentId == null || targetComponentId == null) {
      return false;
    }
    // tests if the ids are not same (the same component)
    if (sourceComponentId == targetComponentId) {
      return false;
    }
    // tests if the connection between two components already exists (one way)
    if (canvasReader.model
        .getComponent(sourceComponentId)
        .connections
        .any((connection) => (connection is ConnectionOut) && (connection.otherComponentId == targetComponentId))) {
      return false;
    }

    // This connects two components (creates a link between), you can define the design of the link with LinkStyle.
    final linkId = canvasWriter.model.connectTwoComponents(
      sourceComponentId: sourceComponentId,
      targetComponentId: targetComponentId,
      linkStyle: LinkStyle(
        arrowType: ArrowType.pointedArrow,
        lineWidth: 1.5,
        backArrowType: ArrowType.centerCircle,
        color: _DiagramColors.link,
      ),
    );

    final link = canvasReader.model.getLink(linkId);
    final from = (canvasReader.model.getComponent(sourceComponentId).data as ComponentViewData).block;
    final to = (canvasReader.model.getComponent(targetComponentId).data as ComponentViewData).block;

    link.data = BlockLink(from: from, to: to);

    Globals.linksBox.put(
      linkId,
      link,
    );

    return true;
  }

  _highlightComponent(String componentId) {
    canvasReader.model.getComponent(componentId).data.showHighlight();
    canvasReader.model.getComponent(componentId).updateComponent();
    selectedComponentId = componentId;
  }

  _hideComponentHighlight(String? componentId) {
    if (componentId != null) {
      canvasReader.model.getComponent(componentId).data.hideHighlight();
      canvasReader.model.getComponent(componentId).updateComponent();
      selectedComponentId = null;
    }
  }
}

abstract class _DiagramColors {
  static final canvas = Globals.myTheme.cardColor;
  static final component = Globals.myTheme.colorScheme.inversePrimary;
  static final componentSelected = complementColor(component);

  static final link = Globals.myTheme.colorScheme.primary;
  static final linkSelected = Colors.amber.shade300;
}
