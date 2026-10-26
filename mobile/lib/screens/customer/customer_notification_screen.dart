import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../repositories/notification_repository.dart';
import '../../widgets/notification_card_widget.dart';

class CustomerNotificationScreen extends StatefulWidget {
  const CustomerNotificationScreen({super.key});

  @override
  State<CustomerNotificationScreen> createState() =>
      _CustomerNotificationScreenState();
}

class _CustomerNotificationScreenState
    extends State<CustomerNotificationScreen> {
  final _repository = NotificationRepository();
  List<NotificationModel> _notifications = [];
  bool _loading = true;
  bool _markingAll = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _repository.getNotifications();
      final payload = response is Map ? response['data'] : null;
      final rows = payload is Map ? payload['data'] : payload;
      final notifications = rows is List
          ? rows
              .whereType<Map>()
              .map((item) =>
                  NotificationModel.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : <NotificationModel>[];
      if (mounted) setState(() => _notifications = notifications);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(NotificationModel notification) async {
    if (notification.isRead) return;
    try {
      await _repository.markRead(notification.id);
      if (mounted) {
        setState(() {
          final index =
              _notifications.indexWhere((item) => item.id == notification.id);
          if (index != -1) {
            final item = _notifications[index];
            _notifications[index] = NotificationModel(
              id: item.id,
              userId: item.userId,
              title: item.title,
              message: item.message,
              type: item.type,
              data: item.data,
              isRead: true,
              readAt: DateTime.now().toIso8601String(),
              createdAt: item.createdAt,
            );
          }
        });
      }
    } catch (_) {
      if (mounted) _showError('Notifikasi gagal ditandai sudah dibaca.');
    }
  }

  Future<void> _markAllRead() async {
    if (_notifications.every((item) => item.isRead)) return;
    setState(() => _markingAll = true);
    try {
      await _repository.markAllRead();
      await _loadNotifications();
    } catch (_) {
      if (mounted) _showError('Semua notifikasi gagal ditandai sudah dibaca.');
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatTime(String? value) {
    final date = DateTime.tryParse(value ?? '')?.toLocal();
    if (date == null) return 'Waktu tidak diketahui';
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  String _tag(NotificationModel item) {
    switch (item.type) {
      case 'chat':
        return 'Chat';
      case 'order_update':
        return 'Order';
      case 'payment':
        return 'Pembayaran';
      case 'review':
        return 'Ulasan';
      default:
        return 'Info';
    }
  }

  IconData _icon(NotificationModel item) {
    switch (item.type) {
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'review':
        return Icons.star_outline_rounded;
      case 'order_update':
        return Icons.receipt_long_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _markingAll ? null : _markAllRead,
            child: _markingAll
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Tandai semua',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _loadNotifications)
              : _notifications.isEmpty
                  ? const _EmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (_, index) {
                          final item = _notifications[index];
                          return NotificationCardWidget(
                            title: item.title,
                            message: item.message,
                            tag: _tag(item),
                            time: _formatTime(item.createdAt),
                            icon: _icon(item),
                            isUnread: !item.isRead,
                            onTap: () => _markRead(item),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Belum ada notifikasi.'));
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 12),
            const Text('Notifikasi tidak dapat dimuat.',
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi'))
          ])));
}
