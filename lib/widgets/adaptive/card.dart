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
  const AdaptiveChip({super.key, required this.child, this.leading});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return Container();
    }
    return Chip(
      text: child,
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
