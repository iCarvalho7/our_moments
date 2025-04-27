import 'package:flutter/material.dart';

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PrimaryAppBar({
    super.key,
    required this.title,
    this.icons,
    this.back,
    this.background,
    this.bottom,
  });

  final String title;
  final List<Widget>? icons;
  final Widget? back;
  final Widget? background;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(title),
      flexibleSpace: background,
      centerTitle: true,
      actions: icons,
      leading: back,
      bottom: bottom != null ? PreferredSize(preferredSize: Size.fromHeight(50.0), child: bottom!) : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
