import 'package:flutter/material.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/services/url_service.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';

const _safetyTips = [
  'Use licensed taxis or e-hailing apps (e.g. Grab) rather than unmetered cabs.',
  "Keep a copy of your passport/ID separate from the original, and save your accommodation's address in case you need to show it.",
  'Be cautious with unlicensed moneychangers — use registered outlets or banks.',
  "Keep valuables out of sight in crowded areas, and don't leave bags unattended.",
  'Stay hydrated and seek shade during midday heat, especially outdoors.',
  "Save your embassy's local contact details before you travel.",
];

class SafetyPage extends StatelessWidget {
  const SafetyPage({super.key});

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
          'Safety & Emergency',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
        actions: [AppBarMore(iconColor: palette.accent)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'In an emergency',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Malaysia's emergency numbers, reachable anywhere",
              style: TextStyle(fontSize: 14, color: palette.textSecondary),
            ),
            const SizedBox(height: 20),
            _EmergencyCard(
              icon: Icons.local_police_rounded,
              iconColor: Colors.red,
              number: '999',
              label: 'Police · Fire · Ambulance',
              palette: palette,
            ),
            const SizedBox(height: 12),
            _EmergencyCard(
              icon: Icons.phone_in_talk_rounded,
              iconColor: Colors.blue,
              number: '112',
              label: 'Mobile emergency (works even without a local SIM)',
              palette: palette,
            ),
            const SizedBox(height: 30),
            Text(
              'Staying safe in KL',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  for (var i = 0; i < _safetyTips.length; i++) ...[
                    if (i != 0) const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 18, color: palette.accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _safetyTips[i],
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.4,
                              color: palette.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String number;
  final String label;
  final HomePalette palette;

  const _EmergencyCard({
    required this.icon,
    required this.iconColor,
    required this.number,
    required this.label,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => UrlService.launchURL('tel:$number'),
        borderRadius: BorderRadius.circular(16),
        child: Semantics(
          button: true,
          label: 'Call $label, $number',
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        number,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(fontSize: 13, color: palette.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.call_rounded, color: iconColor, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
