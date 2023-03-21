import 'package:flutter/material.dart';

import '../../../core/utils/theme/app_theme.dart';
import '../../domain/entities/moment_type.dart';

class TypeToggle extends StatelessWidget {

  final VoidCallback onPressed;
  final bool isSelected;
  final MomentType type;

  const TypeToggle({
    Key? key,
    required this.onPressed,
    required this.isSelected,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: AppThemes.roundedBorder.copyWith(
              border: Border.all(color: Colors.transparent),
              color: isSelected ? type.color : Colors.grey,
            ),
          ),
          const SizedBox(width: 5,),
          Text(
            type.value,
            style: AppThemes.kBodyStyle.copyWith(
              color: isSelected ? Colors.black : Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}
