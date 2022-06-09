import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_state.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/history_container_loading.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/hystory_container.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/moment_form_section_loading.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/select_type_toggle.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/tile_and_description_section.dart';

class AddOrEditMomentPage extends StatefulWidget {
  const AddOrEditMomentPage({Key? key}) : super(key: key);

  @override
  State<AddOrEditMomentPage> createState() => _AddOrEditMomentPageState();
}

class _AddOrEditMomentPageState extends State<AddOrEditMomentPage> {

  @override
  Widget build(BuildContext context) {

    BlocProvider.of<AddOrEditMomentBloc>(context).add(const SetupAddMomentEvent());

    return SafeArea(
      child: BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  CupertinoIcons.arrow_left,
                  color: Colors.black,
                ),
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
    );
  }

  void _createEvent() {
    BlocProvider.of<AddOrEditMomentBloc>(context)
        .add(const AddOrEditMomentEventCreateMoment());
  }

  Widget _buildEmptyPage(AddOrEditMomentState state) {
    if (state is! AddOrEditMomentStateLoading) {
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
    } else {
      return _buildLoadingState();
    }
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          HistoryContainerLoading(),
          MomentFormSectionLoading(),
        ],
      ),
    );
  }
}
