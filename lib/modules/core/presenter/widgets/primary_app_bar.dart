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
      surfaceTintColor: Colors.transparent,
      title: Text(title),
      flexibleSpace: background,
      centerTitle: true,
      actions: icons,
      leading: back,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: DefaultTextStyle.merge(
                  style: Theme.of(context).textTheme.bodySmall,
                  child: bottom!,
                ),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom != null ? 112 : 64);
}
