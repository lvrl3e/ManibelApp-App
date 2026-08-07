import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Static notifications list for now — no backend yet. Once a real
/// notifications API/service exists, replace [_groupedNotifications] with
/// a fetch (and probably move grouping-by-day into the fetch layer too).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // Hardcoded to match the current design. Swap for real data once a
  // notifications backend exists — keep the "Today" / "Yesterday" /
  // etc. day-grouping behavior when you do.
  static final List<_NotificationGroup> _groupedNotifications = [
    _NotificationGroup(
      label: 'Today',
      items: [
        _NotificationItem(
          icon: Icons.bar_chart_rounded,
          iconBackground: const Color(0xFF2E9E6D),
          title: 'Report Received',
          message: 'Your report has been received. Thank you for helping us improve.',
          time: '10:38 AM',
        ),
        _NotificationItem(
          icon: Icons.verified_user_rounded,
          iconBackground: AppColors.logoBlue,
          title: 'Report Update',
          message: 'Your report has been reviewed. Action has been taken.',
          time: '9:48 AM',
        ),
      ],
    ),
    _NotificationGroup(
      label: 'Yesterday',
      items: [
        _NotificationItem(
          icon: Icons.star_rounded,
          iconBackground: const Color(0xFFE5A800),
          title: 'Thank You For Rating!',
          message: 'Thank you! Your rating helps improve our service.',
          time: '8:15 PM',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _groupedNotifications.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: _groupedNotifications.length,
                      itemBuilder: (context, groupIndex) {
                        final group = _groupedNotifications[groupIndex];
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
}

class _NotificationGroup {
  final String label;
  final List<_NotificationItem> items;

  const _NotificationGroup({required this.label, required this.items});
}

class _NotificationItem {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String message;
  final String time;

  const _NotificationItem({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.message,
    required this.time,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;

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
              color: item.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: Colors.white, size: 20),
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
                      item.time,
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