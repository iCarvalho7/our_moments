import 'package:flutter/material.dart';

import 'date_time_section.dart';
import 'description_section.dart';
import 'tile_section.dart';

class MomentFormSection extends StatelessWidget {
  final String? title;
  final String? bodyText;

  const MomentFormSection({
    Key? key,
    this.title,
    this.bodyText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleSection(title: title),
        const DateTimeSection(),
        DescriptionSection(bodyText: bodyText),
      ],
    );
  }
}
