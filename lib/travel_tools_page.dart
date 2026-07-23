import 'package:flutter/material.dart';
import 'package:kltheguide/currency_converter_page.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/phrasebook_page.dart';
import 'package:kltheguide/safety_page.dart';
import 'package:kltheguide/widgets/quick_access_tile.dart';

class _Tool {
  final String label;
  final IconData icon;
  final WidgetBuilder builder;

  const _Tool({
    required this.label,
    required this.icon,
    required this.builder,
  });
}

final _tools = [
  _Tool(
    label: 'Currency Converter',
    icon: Icons.currency_exchange_rounded,
    builder: (_) => const CurrencyConverterPage(),
  ),
  _Tool(
    label: 'Phrasebook',
    icon: Icons.translate_rounded,
    builder: (_) => const PhrasebookPage(),
  ),
  _Tool(
    label: 'Safety & Emergency',
    icon: Icons.health_and_safety_rounded,
    builder: (_) => const SafetyPage(),
  ),
];

// A single grouped entry point for reference tools that don't need frequent
// access (unlike Search or My Trip) — keeps the shared ⋮ menu from growing
// one flat item per tool.
class TravelToolsPage extends StatelessWidget {
  const TravelToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.accent),
        title: Text(
          'Travel Tools',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.05,
        ),
        itemCount: _tools.length,
        itemBuilder: (context, index) {
          final tool = _tools[index];
          return QuickAccessTile(
            icon: tool.icon,
            label: tool.label,
            palette: palette,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: tool.builder)),
          );
        },
      ),
    );
  }
}
