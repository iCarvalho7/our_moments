import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';

class MomentFormSectionLoading extends StatelessWidget {
  const MomentFormSectionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 50,),
        LoadingEffect(
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width / 2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10,),
        LoadingEffect(
          child: Container(
            height: 30,
            width: MediaQuery.of(context).size.width / 2.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20,),
        LoadingEffect(
          child: Container(
            height: 20,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
