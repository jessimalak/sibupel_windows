import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:flutter/material.dart' as material
    show Divider, VerticalDivider;

class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const AdaptiveCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
            border: Border.all(color: MacosTheme.of(context).dividerColor),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: MacosTheme.of(context).pulldownButtonTheme.backgroundColor),
        child: child,
      );
    }
    return Card(
      padding: padding ?? const EdgeInsets.all(12.0),
      child: child,
    );
  }
}

class AdaptiveProgressRing extends StatelessWidget {
  const AdaptiveProgressRing({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return const ProgressCircle();
    }
    return const ProgressRing();
  }
}

class AdaptiveChip extends StatelessWidget {
  final Widget child;
  final Widget? leading;
  final void Function()? onPressed;
  final bool selected;
  const AdaptiveChip(
      {super.key,
      required this.child,
      this.leading,
      this.onPressed,
      this.selected = false});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return GestureDetector(
          onTap: onPressed,
          child: Container(padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: selected ? MacosTheme.of(context).primaryColor : null),
            child: Row(
              children: [
                leading ?? const SizedBox.shrink(),
                child,
              ],
            ),
          ));
    }
    if (selected) {
      return Chip.selected(
        text: child,
        onPressed: onPressed,
        image: leading,
      );
    }
    return Chip(
      image: leading,
      text: child,
      onPressed: onPressed,
    );
  }
}

class AdaptiveDivider extends StatelessWidget {
  final Axis direction;
  final double? size;
  const AdaptiveDivider(
      {super.key, this.direction = Axis.horizontal, this.size});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return direction == Axis.horizontal
          ? SizedBox(
              width: size,
              child: material.Divider(
                color: MacosTheme.of(context).dividerColor,
              ))
          : SizedBox(
              height: size,
              child: material.VerticalDivider(
                  color: MacosTheme.of(context).dividerColor));
    }
    return Divider(
      direction: direction,
      size: size,
    );
  }
}
