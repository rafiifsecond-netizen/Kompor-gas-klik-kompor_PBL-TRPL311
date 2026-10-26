import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../models/order_model.dart';
import '../../widgets/chat_list_item_widget.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class CustomerChatScreen extends StatefulWidget {
  const CustomerChatScreen({super.key});

  @override
  State<CustomerChatScreen> createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  bool _isLoading = true;
  List<OrderModel> _chatOrders = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRealChatList();
  }

  Future<void> _fetchRealChatList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient().get(ApiEndpoints.orders);
      if (response is Map && response['success'] == true) {
        final data = response['data'];
        final list = (data is Map && data['data'] is List)
            ? data['data'] as List
            : (data is List ? data : []);

        setState(() {
          _chatOrders = list
              .map((o) => OrderModel.fromJson(Map<String, dynamic>.from(o as Map)))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _chatOrders = [];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _onNavTap(BuildContext context, int index) {
    final route = switch (index) {
      0 => AppRoutes.customerHome,
      1 => AppRoutes.customerOrderHistory,
      2 => AppRoutes.customerChat,
      3 => AppRoutes.customerProfile,
      _ => null,
    };
    if (route != null && index != 2) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pesan & Chat Teknisi'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchRealChatList,
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetchRealChatList, child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                )
              : _chatOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded, size: 52, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('Belum ada obrolan dengan teknisi', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.customerCatalog),
                            child: const Text('Pesan Servis Sekarang'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchRealChatList,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _chatOrders.length,
                        itemBuilder: (context, i) {
                          final order = _chatOrders[i];
                          final techName = order.technician?.name ?? 'Teknisi KlikKompor';
                          final statusLabel = order.isCompleted ? 'Selesai' : 'Aktif';

                          return ChatListItemWidget(
                            title: techName,
                            lastMessage: 'Obrolan pesanan ${order.orderNumber}',
                            time: order.bookingDate,
                            status: statusLabel,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _ChatDetailScreen(
                                  orderId: order.id,
                                  technicianName: techName,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }
}

class _ChatDetailScreen extends StatefulWidget {
  final int orderId;
  final String technicianName;

  const _ChatDetailScreen({
    required this.orderId,
    required this.technicianName,
  });

  @override
  State<_ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<_ChatDetailScreen> {
  final TextEditingController _ctrl = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchRealMessages();
  }

  Future<void> _fetchRealMessages() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.orderChat(widget.orderId));
      if (res is Map && res['success'] == true) {
        final data = res['data'];
        final list = (data is Map && data['messages'] is List)
            ? data['messages'] as List
            : (data is List ? data : []);

        setState(() {
          _messages = list.map((m) {
            final map = Map<String, dynamic>.from(m as Map);
            return {
              'id': map['id'],
              'text': map['message'] ?? map['text'] ?? '',
              'isMe': map['sender_type'] == 'customer' || map['is_me'] == true,
              'time': map['created_at'] != null ? map['created_at'].toString().split('T').last.substring(0, 5) : '09:30',
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    _ctrl.clear();
    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': TimeOfDay.now().format(context),
      });
    });

    try {
      await ApiClient().post(
        ApiEndpoints.sendChatMessage(widget.orderId),
        data: {'message': text},
      );
    } catch (_) {
      // Message added optimistically
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFEFE2)),
              child: const Icon(Icons.person_rounded, size: 22, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.technicianName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black)),
                Text('Teknisi Resmi', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Text('Mulai percakapan dengan teknisi...', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _messages.length,
                          itemBuilder: (_, i) {
                            final msg = _messages[i];
                            final isMe = msg['isMe'] as bool;
                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMe ? AppColors.primary : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 16),
                                  ),
                                  border: isMe ? null : Border.all(color: AppColors.cardBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg['text'] as String,
                                      style: GoogleFonts.inter(fontSize: 14, color: isMe ? Colors.white : Colors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      msg['time'] as String,
                                      style: GoogleFonts.inter(fontSize: 10, color: isMe ? Colors.white60 : AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            decoration: InputDecoration(
                              hintText: 'Ketik pesan ke teknisi...',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              filled: true,
                              fillColor: AppColors.inputBg,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
