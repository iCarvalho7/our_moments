import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingEffect extends StatelessWidget {
  final Widget child;

  const LoadingEffect({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.white,
      child: child,
    );
  }
}
