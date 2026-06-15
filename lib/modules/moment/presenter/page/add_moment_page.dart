import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_or_edit_moment_bloc.dart';
import '../widget/date_time_section.dart';
import '../widget/description_section.dart';
import '../widget/history_container_loading.dart';
import '../../../photos/presentation/widget/photos_container.dart';
import '../widget/moment_form_section_loading.dart';
import '../widget/select_type_toggle.dart';
import '../widget/tile_section.dart';

class AddOrEditMomentPage extends StatelessWidget {
  const AddOrEditMomentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text('Novo momento'),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(CupertinoIcons.arrow_left),
          ),
        ),
        body: BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
          builder: (context, state) {
            return _buildPage(state, context);
          },
        ),
      ),
    );
  }

  Widget _buildPage(AddOrEditMomentState state, BuildContext context) {
    if (state is AddOrEditMomentStateLoading) {
      return _buildLoadingState();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SelectTypeToggle(),
        const PhotosContainer(),
        const DateTimeSection(),
        const TitleSection(),
        const DescriptionSection(),
        BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ElevatedButton(
                onPressed: state.moment.isAllFieldsFilled ? () => _createEvent(context) : null,
                child: Text(
                  state.moment.isEditing ? 'Salvar edição' : 'Registrar eternamente',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(10.0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HistoryContainerLoading(),
          MomentFormSectionLoading(),
        ],
      ),
    );
  }

  void _createEvent(BuildContext context) {
    BlocProvider.of<AddOrEditMomentBloc>(context)
        .add(const AddOrEditMomentEventCreateOrUpdateMoment());
  }
}
