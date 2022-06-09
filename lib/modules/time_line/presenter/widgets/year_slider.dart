import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

class TextSlider extends StatefulWidget {
  final Function(String) onChangeItem;
  final List<String> carrouselItems;
  final bool isEnabled;

  const TextSlider({
    Key? key,
    required this.onChangeItem,
    required this.carrouselItems,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<TextSlider> createState() => _TextSliderState();
}

class _TextSliderState extends State<TextSlider> {
  final _carrouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: widget.isEnabled ? Colors.black : Colors.grey,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _carrouselController.previousPage(),
            icon: Icon(
              CupertinoIcons.left_chevron,
              color: widget.isEnabled ? Colors.black : Colors.grey,
            ),
          ),
          SizedBox(
            height: 50,
            child: CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1,
                aspectRatio: 16 / 6,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  widget.onChangeItem(widget.carrouselItems[index]);
                },
              ),
              carouselController: _carrouselController,
              items: widget.carrouselItems
                  .map(
                    (item) => Center(
                      child: Text(
                        item,
                        style: AppThemes.kLightHeadLineStyle,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          IconButton(
            onPressed: () => _carrouselController.nextPage(),
            icon: Icon(
              CupertinoIcons.right_chevron,
              color: widget.isEnabled ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
