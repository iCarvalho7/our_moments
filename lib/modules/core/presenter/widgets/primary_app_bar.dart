import 'package:flutter/material.dart';

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {

  const PrimaryAppBar(
      {super.key, required this.title, this.icons, this.back, this.background,});

  final String title;
  final List<Widget>? icons;
  final Widget? back;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(title),
      flexibleSpace: background,
      centerTitle: true,
      actions: icons,
      leading: back,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
