import 'package:flutter/material.dart';
import '../../../core/presenter/widgets/loading_effect.dart';
import '../../../core/utils/theme/app_theme.dart';

class HistoryContainerLoading extends StatelessWidget {
  const HistoryContainerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = context.palette.surface;
    return SizedBox(
      height: 55,
      child: ListView.builder(
          itemCount: 3,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return LoadingEffect(
              child: Container(
                height: 55,
                width: 55,
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: surface,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
    );
  }
}