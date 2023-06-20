import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_or_edit_moment_bloc.dart';

class DescriptionSection extends StatelessWidget {

  const DescriptionSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      builder: (context, state) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              style: Theme.of(context).textTheme.titleMedium,
              cursorColor: Colors.black,
              initialValue: state.moment.body,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                hintText: 'Descreva em detalhes (ou não) esse momento',
                floatingLabelStyle: Theme.of(context).textTheme.titleMedium,
                labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey
                ),
                border: InputBorder.none,
              ),
              onChanged: (bodyText) {
                BlocProvider.of<AddOrEditMomentBloc>(context)
                    .add(AddOrEditMomentEvenTypeBodyText(bodyText: bodyText));
              },
            ),
          ),
        );
      }
    );
  }
}
