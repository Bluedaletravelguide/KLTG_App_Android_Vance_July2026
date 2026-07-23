import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kltheguide/services/notification_inbox_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    NotificationInboxService.resetForTesting();
  });

  test('starts empty on a fresh install', () async {
    await NotificationInboxService.ensureLoaded();
    expect(NotificationInboxService.items.value, isEmpty);
  });

  test('add puts the newest notification first', () async {
    await NotificationInboxService.add('New Voucher', 'Check out our latest deal');
    await NotificationInboxService.add('Trip Reminder', "Don't forget Day 2");

    final items = NotificationInboxService.items.value;
    expect(items, hasLength(2));
    expect(items[0].title, 'Trip Reminder');
    expect(items[1].title, 'New Voucher');
  });

  test('clear empties the inbox', () async {
    await NotificationInboxService.add('New Voucher', 'Check out our latest deal');
    await NotificationInboxService.clear();
    expect(NotificationInboxService.items.value, isEmpty);
  });

  test('state round-trips through persistence', () async {
    await NotificationInboxService.add('New Voucher', 'Check out our latest deal');

    NotificationInboxService.resetForTesting();
    await NotificationInboxService.ensureLoaded();

    final items = NotificationInboxService.items.value;
    expect(items, hasLength(1));
    expect(items.single.title, 'New Voucher');
    expect(items.single.body, 'Check out our latest deal');
  });
}
