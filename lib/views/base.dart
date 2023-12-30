import 'dart:async';

import 'package:concept_designer/common/globals.dart';
import 'package:concept_designer/common/misc.dart';
import 'package:flutter/material.dart';

class BaseView extends StatelessWidget {
  BaseView({
    super.key,
    required this.title,
    required this.children,
    this.onDoubleTap,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
  });

  final String title;
  final List<Widget> children;
  final void Function()? onDoubleTap;
  final void Function()? onTap;
  final void Function()? onDelete;
  final bool isSelected;

  final _timer = ValueNotifier(Timer(Duration.zero, () {}));

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Globals.myTheme.colorScheme.inversePrimary
                : Colors.transparent, // Border color based on selection
            width: 4.0, // Border width
          ),
          borderRadius: BorderRadius.circular(16.0), // Optional: Add rounded corners
        ),
        child: InkWell(
          onTap: () {
            if (_timer.value.isActive) {
              _timer.value.cancel();
              onDoubleTap == null ? null : onDoubleTap!();
            } else {
              _timer.value = Timer(Durations.medium2, onTap ?? () {});
            }
          },
          mouseCursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Globals.myTheme.textTheme.titleLarge!,
                        ),
                      ),
                      DeleteIcon(onDelete: onDelete ?? () {}),
                    ],
                  ),
                  const HDivider(),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
