import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

class ColoredContainer extends StatelessWidget {
  final Widget child;

  const ColoredContainer({Key? key, required this.child,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      decoration: AppThemes.coloredBorder,
      height: 55,
      width: 55,
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(40),
        ),
        child: ClipOval(child: child),
      ),
    );
  }
}
