import 'package:flutter/material.dart';

import 'date_time_section.dart';
import 'description_section.dart';
import 'tile_section.dart';

class MomentFormSection extends StatelessWidget {
  final String? title;
  final String? bodyText;
  final String? date;

  const MomentFormSection({
    Key? key,
    this.title,
    this.bodyText,
    this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          TitleSection(title: title),
          DateTimeSection(dateText: date),
          DescriptionSection(bodyText: bodyText),
        ],
      ),
    );
  }
}
