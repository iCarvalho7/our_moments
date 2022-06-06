import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/date_time_section.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/description_section.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/tile_section.dart';

class MomentFormSection extends StatelessWidget {
  const MomentFormSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleSection(),
        DateTimeSection(),
        const DescriptionSection(),
      ],
    );
  }
}

