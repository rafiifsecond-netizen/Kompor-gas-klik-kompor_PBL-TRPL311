import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/chat_list_item_widget.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class CustomerChatScreen extends StatelessWidget {
  const CustomerChatScreen({super.key});

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
      appBar: AppBar(title: const Text('Pesan'), backgroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ChatListItemWidget(
            title: 'Ahmad Subagyo',
            lastMessage: 'Saya sudah sampai di depan rumah bapak.',
            time: '09:45',
            status: 'Aktif',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _ChatDetailScreen(technicianName: 'Ahmad Subagyo'))),
          ),
          ChatListItemWidget(
            title: 'Budi Wirawan',
            lastMessage: 'Terima kasih sudah menggunakan layanan kami.',
            time: 'Kemarin',
            status: 'Selesai',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _ChatDetailScreen(technicianName: 'Budi Wirawan'))),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }
}

class _ChatDetailScreen extends StatefulWidget {
  final String technicianName;
  const _ChatDetailScreen({required this.technicianName});
  @override
  State<_ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<_ChatDetailScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Halo, saya Ahmad. Saya sudah dalam perjalanan ke lokasi Anda.', 'isMe': false, 'time': '09:30'},
    {'text': 'Baik, terima kasih. Saya tunggu.', 'isMe': true, 'time': '09:31'},
    {'text': 'Estimasi 15 menit lagi pak.', 'isMe': false, 'time': '09:32'},
    {'text': 'Saya sudah sampai di depan rumah bapak.', 'isMe': false, 'time': '09:45'},
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(children: [
          Container(width: 36, height: 36, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFEFE2)), child: const Icon(Icons.person_rounded, size: 22, color: AppColors.primary)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.technicianName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black)),
            Text('Teknisi', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
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
                  child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                    Text(msg['text'] as String, style: GoogleFonts.inter(fontSize: 14, color: isMe ? Colors.white : Colors.black)),
                    const SizedBox(height: 4),
                    Text(msg['time'] as String, style: GoogleFonts.inter(fontSize: 10, color: isMe ? Colors.white60 : AppColors.textMuted)),
                  ]),
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
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    filled: true, fillColor: AppColors.inputBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_ctrl.text.trim().isEmpty) return;
                  setState(() {
                    _messages.add({'text': _ctrl.text.trim(), 'isMe': true, 'time': TimeOfDay.now().format(context)});
                    _ctrl.clear();
                  });
                },
                child: Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
