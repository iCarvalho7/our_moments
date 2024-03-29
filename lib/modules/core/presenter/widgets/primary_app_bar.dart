import 'package:flutter/material.dart';

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {

  const PrimaryAppBar({super.key, required this.title, this.icons, this.back});

  final String title;
  final List<Widget>? icons;
  final Widget? back;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(title),
      centerTitle: true,
      actions: icons,
      leading: back,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
