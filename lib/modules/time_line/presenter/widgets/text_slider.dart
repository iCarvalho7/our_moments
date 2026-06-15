import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/theme/app_theme.dart';

class TextSlider extends StatefulWidget {
  final Function(String) onChangeItem;
  final List<String> carrouselItems;
  final bool isEnabled;
  final int selectedIndex;

  const TextSlider({
    super.key,
    required this.onChangeItem,
    required this.carrouselItems,
    required this.selectedIndex,
    this.isEnabled = true,
  });

  @override
  State<TextSlider> createState() => _TextSliderState();
}

class _TextSliderState extends State<TextSlider> {
  final _carrouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final activeColor = widget.isEnabled ? palette.onSurface : palette.onSurfaceMuted;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => widget.isEnabled ? _carrouselController.previousPage() : null,
          icon: Icon(CupertinoIcons.left_chevron, color: activeColor),
        ),
        SizedBox(
          height: 50,
          child: CarouselSlider(
            disableGesture: true,
            options: CarouselOptions(
              initialPage: widget.selectedIndex,
              viewportFraction: 1,
              enlargeCenterPage: true,
              onPageChanged: (index, _) {
                widget.onChangeItem(widget.carrouselItems[index]);
              },
            ),
            carouselController: _carrouselController,
            items: widget.carrouselItems
                .map(
                  (item) => Center(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: activeColor),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        IconButton(
          onPressed: () => widget.isEnabled ? _carrouselController.nextPage() : null,
          icon: Icon(CupertinoIcons.right_chevron, color: activeColor),
        ),
      ],
    );
  }
}
