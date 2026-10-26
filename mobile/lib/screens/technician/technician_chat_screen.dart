import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../providers/auth_provider.dart';

class TechnicianChatInboxScreen extends StatefulWidget {
  const TechnicianChatInboxScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<TechnicianChatInboxScreen> createState() =>
      _TechnicianChatInboxScreenState();
}

class _TechnicianChatInboxScreenState extends State<TechnicianChatInboxScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;
  String _filter = 'Semua';
  String _search = '';
  List<Map<String, dynamic>> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
    _searchController.addListener(() {
      if (_search != _searchController.text) {
        setState(() => _search = _searchController.text.trim().toLowerCase());
      }
    });
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await ApiClient().get(ApiEndpoints.technicianChats);
      final data = response is Map ? response['data'] : null;
      if (response is! Map || response['success'] != true || data is! List) {
        throw Exception('Daftar pesan tidak dapat dimuat.');
      }
      if (!mounted) return;
      setState(() {
        _chats = data
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _visibleChats {
    return _chats.where((chat) {
      final customer = chat['customer'] is Map
          ? Map<String, dynamic>.from(chat['customer'] as Map)
          : <String, dynamic>{};
      final order = chat['order'] is Map
          ? Map<String, dynamic>.from(chat['order'] as Map)
          : <String, dynamic>{};
      final customerName = (customer['name'] ?? 'Pelanggan').toString();
      final orderNumber = (order['order_number'] ?? '').toString();
      final matchesSearch = _search.isEmpty ||
          customerName.toLowerCase().contains(_search) ||
          orderNumber.toLowerCase().contains(_search);
      final unread = _asInt(chat['unread_count']) > 0;
      final active = !['completed', 'cancelled'].contains(order['status']);
      final matchesFilter = switch (_filter) {
        'Aktif' => active,
        'Belum dibaca' => unread,
        _ => true,
      };
      return matchesSearch && matchesFilter;
    }).toList();
  }

  int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  Future<void> _openChat(Map<String, dynamic> chat) async {
    final customer = chat['customer'] is Map
        ? Map<String, dynamic>.from(chat['customer'] as Map)
        : <String, dynamic>{};
    final order = chat['order'] is Map
        ? Map<String, dynamic>.from(chat['order'] as Map)
        : <String, dynamic>{};
    final orderId = _asInt(chat['order_id']);
    if (orderId == 0) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _TechnicianChatDetailScreen(
          orderId: orderId,
          customerName: (customer['name'] ?? 'Pelanggan').toString(),
          orderDate:
              order['created_at']?.toString() ?? chat['created_at']?.toString(),
        ),
      ),
    );
    if (mounted) _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    final chats = _visibleChats;
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Kembali',
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 22),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints.tightFor(width: 30, height: 36),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pesan',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Muat ulang',
                    onPressed: _loadChats,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Cari pelanggan atau pesanan',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 17),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 34, minHeight: 34),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    fillColor: const Color(0xFFF3EEF6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: Color(0xFFD5CFD9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: Color(0xFFD5CFD9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final filter in ['Semua', 'Aktif', 'Belum dibaca'])
                    Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: _ChatFilterChip(
                        label: filter,
                        selected: _filter == filter,
                        onTap: () => setState(() => _filter = filter),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : _error != null
                      ? _InboxMessage(
                          icon: Icons.wifi_off_rounded,
                          text: _error!,
                          actionLabel: 'Coba lagi',
                          onAction: _loadChats,
                        )
                      : chats.isEmpty
                          ? RefreshIndicator(
                              onRefresh: _loadChats,
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: 260,
                                    child: _InboxMessage(
                                      icon: Icons.chat_bubble_outline_rounded,
                                      text: _chats.isEmpty
                                          ? 'Belum ada percakapan.'
                                          : 'Tidak ada pesan yang cocok.',
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadChats,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                                itemCount: chats.length,
                                itemBuilder: (context, index) => _ChatInboxTile(
                                  chat: chats[index],
                                  onTap: () => _openChat(chats[index]),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatFilterChip extends StatelessWidget {
  const _ChatFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : const Color(0xFFD8D8D8),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatInboxTile extends StatelessWidget {
  const _ChatInboxTile({required this.chat, required this.onTap});

  final Map<String, dynamic> chat;
  final VoidCallback onTap;

  int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  @override
  Widget build(BuildContext context) {
    final customer = chat['customer'] is Map
        ? Map<String, dynamic>.from(chat['customer'] as Map)
        : <String, dynamic>{};
    final order = chat['order'] is Map
        ? Map<String, dynamic>.from(chat['order'] as Map)
        : <String, dynamic>{};
    final latest = chat['latest_message'] is Map
        ? Map<String, dynamic>.from(chat['latest_message'] as Map)
        : <String, dynamic>{};
    final unreadCount = _asInt(chat['unread_count']);
    final done = ['completed', 'cancelled'].contains(order['status']);
    final timestamp = DateTime.tryParse(
      (latest['created_at'] ?? chat['last_message_at'] ?? '').toString(),
    )?.toLocal();
    final time = timestamp == null
        ? ''
        : '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    final preview = (latest['message'] ?? 'Mulai percakapan').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD1D1D1)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 9, 6, 9),
          child: Row(
            children: [
              const _CustomerAvatar(size: 38),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (customer['name'] ?? 'Pelanggan').toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: done
                                ? const Color(0xFF43BA75)
                                : const Color(0xFFE4E4E4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            done ? 'Selesai' : 'Aktif',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: done ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight:
                            unreadCount > 0 ? FontWeight.w700 : FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  width: 17,
                  height: 17,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TechnicianChatDetailScreen extends StatefulWidget {
  const _TechnicianChatDetailScreen({
    required this.orderId,
    required this.customerName,
    this.orderDate,
  });

  final int orderId;
  final String customerName;
  final String? orderDate;

  @override
  State<_TechnicianChatDetailScreen> createState() =>
      _TechnicianChatDetailScreenState();
}

class _TechnicianChatDetailScreenState
    extends State<_TechnicianChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  List<Map<String, dynamic>> _messages = [];
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _userId = context.read<AuthProvider>().user?.id ?? 0;
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final response =
          await ApiClient().get(ApiEndpoints.orderChat(widget.orderId));
      final data = response is Map ? response['data'] : null;
      final rows = data is Map ? data['messages'] : null;
      if (response is! Map || response['success'] != true || rows is! List) {
        throw Exception('Pesan tidak dapat dimuat.');
      }
      if (!mounted) return;
      setState(() {
        _messages = rows
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
        _isLoading = false;
        _error = null;
      });
      _scrollToLatest();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _timeLabel(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _headerDate() {
    final date = DateTime.tryParse(widget.orderDate ?? '')?.toLocal();
    if (date == null) return 'Percakapan pesanan';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      await ApiClient().post(
        ApiEndpoints.sendChatMessage(widget.orderId),
        data: {'message': text, 'message_type': 'text'},
      );
      if (!mounted) return;
      _messageController.clear();
      await _loadMessages();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesan gagal dikirim: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, size: 21),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const _CustomerAvatar(size: 34),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _headerDate(),
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang pesan',
            onPressed: _loadMessages,
            icon: const Icon(Icons.refresh_rounded, size: 19),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : _error != null
                    ? _InboxMessage(
                        icon: Icons.wifi_off_rounded,
                        text: _error!,
                        actionLabel: 'Coba lagi',
                        onAction: _loadMessages,
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada pesan. Mulai percakapan di sini.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isMe =
                                  _asInt(message['sender_id']) == _userId;
                              final text =
                                  (message['message'] ?? '').toString();
                              return _MessageBubble(
                                text: text,
                                time: _timeLabel(message['created_at']),
                                isMe: isMe,
                              );
                            },
                          ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE7E7E7))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Lampiran',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lampiran belum tersedia.')),
                    ),
                    icon: const Icon(Icons.attach_file_rounded,
                        color: AppColors.textMuted, size: 20),
                    constraints: const BoxConstraints.tightFor(width: 40),
                    padding: EdgeInsets.zero,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: GoogleFonts.inter(fontSize: 11),
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFE4E4E4),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: IconButton(
                      tooltip: 'Kirim pesan',
                      onPressed: _isSending ? null : _sendMessage,
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.45),
                      ),
                      icon: _isSending
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 17),
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

  int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.text,
    required this.time,
    required this.isMe,
  });

  final String text;
  final String time;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const _CustomerAvatar(size: 28),
            const SizedBox(width: 7),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.68,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : const Color(0xFFB8B8B8),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10),
                      topRight: const Radius.circular(10),
                      bottomLeft: Radius.circular(isMe ? 10 : 3),
                      bottomRight: Radius.circular(isMe ? 3 : 10),
                    ),
                  ),
                  child: Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      height: 1.3,
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    color: AppColors.textSecondary,
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

class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE8D9FF),
      ),
      child: Icon(
        Icons.person_outline_rounded,
        size: size * 0.68,
        color: const Color(0xFF60409B),
      ),
    );
  }
}

class _InboxMessage extends StatelessWidget {
  const _InboxMessage({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 38, color: AppColors.textMuted),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 10),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
