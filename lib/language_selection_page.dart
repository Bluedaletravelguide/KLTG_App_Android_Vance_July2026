import 'package:flutter/material.dart';
import 'package:kltheguide/generated/l10n.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/l10n/app_languages.dart';
import 'package:kltheguide/main.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentCode = Localizations.localeOf(context).languageCode;
    final palette = HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.accent),
        title: Text(
          S.of(context).pickALanguage,
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            itemCount: kAppLanguages.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: palette.textSecondary.withValues(alpha: 0.15),
            ),
            itemBuilder: (context, index) {
              final language = kAppLanguages[index];
              final isSelected = language.code == currentCode;

              return ListTile(
                leading: Text(language.flag, style: const TextStyle(fontSize: 24)),
                title: Text(
                  language.nativeName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                subtitle: language.nativeName == language.englishName
                    ? null
                    : Text(
                        language.englishName,
                        style: TextStyle(color: palette.textSecondary),
                      ),
                trailing:
                    isSelected ? Icon(Icons.check_circle, color: palette.accent) : null,
                selected: isSelected,
                selectedTileColor: palette.accent.withValues(alpha: 0.1),
                onTap: () {
                  MyApp.setLocale(context, language.locale);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(language.nativeName),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: palette.accent,
                    ),
                  );

                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
