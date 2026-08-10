import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Real, app-generated notifications (trip completed, rating submitted,
/// report submitted, etc.) — pushed here via [NotificationsScreen.push]
/// whenever one of those events actually happens elsewhere in the app.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final List<AppNotification> _notifications = [];

  /// Records a new notification at the top of the feed.
  static void push(AppNotification notification) {
    _notifications.insert(0, notification);
  }

  static List<_NotificationGroup> get _groupedNotifications {
    if (_notifications.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String labelFor(DateTime time) {
      final day = DateTime(time.year, time.month, time.day);
      if (day == today) return 'Today';
      if (day == yesterday) return 'Yesterday';
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[time.month - 1]} ${time.day}, ${time.year}';
    }

    final groups = <String, List<AppNotification>>{};
    for (final notification in _notifications) {
      groups.putIfAbsent(labelFor(notification.time), () => []).add(notification);
    }

    return groups.entries
        .map((entry) => _NotificationGroup(label: entry.key, items: entry.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupedNotifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: groups.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      itemCount: groups.length,
                      itemBuilder: (context, groupIndex) {
                        final group = groups[groupIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (groupIndex != 0) const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10, left: 2),
                              child: Text(
                                group.label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            ...group.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _NotificationCard(item: item),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================
  // Same yellow banner + back button + title/subtitle convention used
  // across the other commuter screens (Settings, Change Password,
  // Emergency Hotlines, History). Fixed (not scrolling) since the body
  // below it swaps between a list and a centered empty state.

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFFFFDE7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).maybePop(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.arrow_back, size: 18, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single real notification. [time] drives both the day grouping and the
/// displayed time-of-day.
class AppNotification {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String message;
  final DateTime time;

  const AppNotification({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.message,
    required this.time,
  });

  String get timeLabel {
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }
}

class _NotificationGroup {
  final String label;
  final List<AppNotification> items;

  const _NotificationGroup({required this.label, required this.items});
}

class _NotificationCard extends StatelessWidget {
  final AppNotification item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.logoBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.timeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            size: 56,
            color: Colors.black26,
          ),
          const SizedBox(height: 12),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}