import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/theme/app_theme.dart';
import '../../domain/entities/moment.dart';
import '../bloc/add_or_edit_moment_bloc.dart';
import '../page/location_picker_page.dart';

class LocationSection extends StatefulWidget {
  const LocationSection({super.key});

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<AddOrEditMomentBloc>().state.moment.locationName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openPicker(Moment moment) async {
    final bloc = context.read<AddOrEditMomentBloc>();
    final result = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialLatitude: moment.latitude,
          initialLongitude: moment.longitude,
          initialName: moment.locationName,
        ),
      ),
    );
    if (result != null) {
      bloc.add(AddOrEditMomentEventSetLocation(
        latitude: result.latitude,
        longitude: result.longitude,
        name: result.name,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocListener<AddOrEditMomentBloc, AddOrEditMomentState>(
      listenWhen: (p, c) => p.moment.locationName != c.moment.locationName,
      listener: (context, state) {
        // Reflect a name set elsewhere (the map picker) without fighting typing.
        if (_controller.text != state.moment.locationName) {
          _controller.text = state.moment.locationName;
        }
      },
      child: BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
        builder: (context, state) {
          final moment = state.moment;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 4),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadii.input),
              ),
              child: Row(
                children: [
                  Icon(
                    moment.hasLocation ? Icons.place_rounded : Icons.place_outlined,
                    color: moment.hasLocation ? palette.primary : palette.onSurfaceMuted,
                    size: 20,
                  ),
                  kSpacerWidth12,
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      style: Theme.of(context).textTheme.bodyLarge,
                      cursorColor: palette.primary,
                      decoration: InputDecoration(
                        filled: false,
                        isDense: true,
                        hintText: 'Onde foi?',
                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: palette.onSurfaceMuted,
                            ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: (value) => context
                          .read<AddOrEditMomentBloc>()
                          .add(AddOrEditMomentEventTypeLocation(location: value)),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Escolher no mapa',
                    icon: Icon(
                      moment.hasLocation ? Icons.map_rounded : Icons.add_location_alt_outlined,
                      color: palette.primary,
                    ),
                    onPressed: () => _openPicker(moment),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
