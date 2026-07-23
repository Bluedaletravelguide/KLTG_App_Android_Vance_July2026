import 'package:flutter/material.dart';
import 'package:kltheguide/about_us.dart';
import 'package:kltheguide/contact_us.dart';
import 'package:kltheguide/home_page_v2.dart';
import '../generated/l10n.dart';

// Search, My Trip, Bookmarks, Notifications, and Travel Tools all moved to
// a Quick Access row on Home (HomeScreenV2._buildQuickAccess) — Home is
// always one tap away via the bottom nav, so this menu now only holds the
// two truly generic, same-everywhere entries.
class AppBarMore extends StatelessWidget {
  const AppBarMore({
    super.key,
    this.iconColor,
    this.padding,
    this.extraItems = const [],
    this.onExtraSelected,
  });

  final Color? iconColor;
  final EdgeInsetsGeometry? padding;

  // Lets individual pages (e.g. the article detail page's "Open in Browser")
  // add their own entries above the standard About/Contact ones without
  // every call site having to duplicate that shared menu.
  final List<PopupMenuEntry<String>> extraItems;
  final ValueChanged<String>? onExtraSelected;

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: iconColor),
      padding: padding ?? const EdgeInsets.all(8),
      color: palette.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      offset: const Offset(0, 50),
      onSelected: (value) {
        if (value == S.of(context).contactUs) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ContactUsPage(),
          ));
        } else if (value == S.of(context).aboutUs) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AboutUsPage(),
          ));
        } else {
          onExtraSelected?.call(value);
        }
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          ...extraItems,
          if (extraItems.isNotEmpty) const PopupMenuDivider(height: 1),
          _menuItem(palette, S.of(context).aboutUs, Icons.info_outline),
          _menuItem(palette, S.of(context).contactUs, Icons.contact_support_outlined),
        ];
      },
    );
  }

  PopupMenuItem<String> _menuItem(HomePalette palette, String label, IconData icon) {
    return PopupMenuItem<String>(
      value: label,
      child: Row(
        children: [
          Icon(icon, color: palette.accent, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 15, color: palette.textPrimary)),
        ],
      ),
    );
  }
}
