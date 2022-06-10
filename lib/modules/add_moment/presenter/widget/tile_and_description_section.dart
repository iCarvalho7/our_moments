import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/date_time_section.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/description_section.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/tile_section.dart';

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
