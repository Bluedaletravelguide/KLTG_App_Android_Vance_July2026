import 'package:flutter/material.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/theme/app_icons.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';
import 'package:kltheguide/services/url_service.dart';
import 'generated/l10n.dart';
import 'services/api_service.dart';
import 'widgets/api_future_view.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

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
          S.of(context).contactUs,
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
        actions: [AppBarMore(iconColor: palette.accent)],
      ),
      body: ApiFutureView<Map<String, dynamic>>(
        load: fetchSiteInfo,
        builder: (context, info) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).contactUs,
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "We're here to help you",
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 14,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Contact Cards Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildContactCard(
                      icon: Icons.email_rounded,
                      iconColor: Colors.red,
                      title: S.of(context).email,
                      subtitle: field(info, 'email'),
                      onTap: () =>
                          UrlService.launchURL('mailto:${field(info, 'email')}'),
                      palette: palette,
                    ),
                    const SizedBox(height: 12),
                    _buildContactCard(
                      icon: MyFlutterApp.whatsapp,
                      iconColor: Colors.green,
                      title: S.of(context).whatsapp,
                      subtitle: field(info, 'whatsapp'),
                      onTap: () =>
                          UrlService.launchURL(whatsappUri(field(info, 'whatsapp'))),
                      palette: palette,
                    ),
                    const SizedBox(height: 12),
                    _buildContactCard(
                      icon: Icons.phone_rounded,
                      iconColor: Colors.blue,
                      title: S.of(context).phone,
                      subtitle: field(info, 'phone'),
                      onTap: () => UrlService.launchURL(telUri(field(info, 'phone'))),
                      palette: palette,
                    ),
                    const SizedBox(height: 12),
                    _buildContactCard(
                      icon: Icons.location_on_rounded,
                      iconColor: Colors.orange,
                      title: S.of(context).address,
                      subtitle: field(info, 'address'),
                      onTap: () =>
                          UrlService.launchURL(field(info, 'address_map_url')),
                      showArrow: true,
                      palette: palette,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Working Hours Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: palette.accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.access_time_rounded,
                          color: palette.accent,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).workingHours,
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildWorkingHoursRow(
                          'Monday - Friday', field(info, 'hours_weekday'), palette),
                      const SizedBox(height: 8),
                      _buildWorkingHoursRow(
                          'Saturday', field(info, 'hours_saturday'), palette),
                      const SizedBox(height: 8),
                      _buildWorkingHoursRow('Sunday & Public Holidays',
                          field(info, 'hours_sunday'), palette),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required HomePalette palette,
    bool showArrow = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.1),
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
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: palette.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: palette.textSecondary,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkingHoursRow(String day, String hours, HomePalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: palette.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 14,
              color: palette.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: 14,
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

}
