import 'package:flutter/material.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/models/notification_record.dart';
import 'package:kltheguide/services/notification_inbox_service.dart';
import 'package:kltheguide/widgets/state_views.dart';

class NotificationInboxPage extends StatefulWidget {
  const NotificationInboxPage({super.key});

  @override
  State<NotificationInboxPage> createState() => _NotificationInboxPageState();
}

class _NotificationInboxPageState extends State<NotificationInboxPage> {
  @override
  void initState() {
    super.initState();
    NotificationInboxService.ensureLoaded();
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

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
          'Notifications',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
        actions: [
          ValueListenableBuilder<List<NotificationRecord>>(
            valueListenable: NotificationInboxService.items,
            builder: (context, items, _) => IconButton(
              tooltip: 'Clear all',
              icon: Icon(Icons.delete_sweep_outlined, color: palette.accent),
              onPressed: items.isEmpty ? null : () => NotificationInboxService.clear(),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<NotificationRecord>>(
        valueListenable: NotificationInboxService.items,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const EmptyStateView(
              icon: Icons.notifications_none_rounded,
              message: "You're all caught up — no notifications yet.",
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: palette.accent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_rounded, color: palette.accent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title.isEmpty ? '(No title)' : item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: palette.textPrimary,
                            ),
                          ),
                          if (item.body.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.body,
                              style: TextStyle(fontSize: 13.5, color: palette.textSecondary),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            _relativeTime(item.receivedAt),
                            style: TextStyle(fontSize: 11.5, color: palette.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
