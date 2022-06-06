import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/dependencie_injection/injection.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_state.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/hystory_container.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/select_type_toggle.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/tile_and_description_section.dart';

class AddOrEditMomentPage extends StatefulWidget {
  const AddOrEditMomentPage({Key? key}) : super(key: key);

  @override
  State<AddOrEditMomentPage> createState() => _AddOrEditMomentPageState();
}

class _AddOrEditMomentPageState extends State<AddOrEditMomentPage> {
  final addOrEditBloc = getIt<AddOrEditMomentBloc>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (_) => addOrEditBloc,
        child: BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(CupertinoIcons.arrow_left, color: Colors.black,),
                ),
                backgroundColor: Colors.white10,
                elevation: 0,
                actions: [
                  IconButton(
                    onPressed: () => state is AddOrEditMomentStateAllFilled
                        ? _createEvent()
                        : null,
                    icon: Icon(
                      Icons.done,
                      color: state is AddOrEditMomentStateAllFilled
                          ? Colors.green
                          : Colors.grey,
                    ),
                  )
                ],
              ),
              body: _buildEmptyPage(state),
            );
          },
        ),
      ),
    );
  }

  void _createEvent() {
    BlocProvider.of<AddOrEditMomentBloc>(context)
        .add(const AddOrEditMomentEventCreateMoment());
  }

  Widget _buildEmptyPage(AddOrEditMomentState state) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: const [
              SelectTypeToggle(),
              Divider(),
              HistoryContainer(),
              MomentFormSection(),
            ],
          ),
        ),
      );
  }

}
