import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/service_model.dart';
import '../../repositories/service_repository.dart';

class CustomerCatalogScreen extends StatefulWidget {
  const CustomerCatalogScreen({super.key});
  @override
  State<CustomerCatalogScreen> createState() => _CustomerCatalogScreenState();
}

class _CustomerCatalogScreenState extends State<CustomerCatalogScreen> {
  final _search = TextEditingController();
  final _repository = ServiceRepository();
  List<ServiceModel> _services = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _repository.getServices();
      if (mounted) {
        setState(() => _services = rows.map(ServiceModel.fromJson).toList());
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.toLowerCase();
    final visible = _services
        .where((service) =>
            service.name.toLowerCase().contains(query) ||
            (service.category?.name.toLowerCase().contains(query) ?? false))
        .toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('Katalog Layanan'),
          backgroundColor: Colors.white,
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh))
          ]),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                    hintText: 'Cari layanan...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder()))),
        Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _Error(message: _error!, retry: _load)
                    : visible.isEmpty
                        ? const Center(
                            child: Text('Belum ada layanan tersedia.'))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: visible.length,
                                itemBuilder: (_, index) =>
                                    _card(visible[index])))),
      ]),
    );
  }

  Widget _card(ServiceModel service) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: const CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.build_rounded, color: AppColors.primary)),
          title: Text(service.name,
              style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          subtitle: Text(
            '${service.category?.name ?? 'Layanan'}\n${AppConstants.formatCurrency(service.price)} • ${service.estimatedDurationMinutes} menit',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(
              context, AppRoutes.customerServiceDetail,
              arguments: {
                'id': service.id,
                'name': service.name,
                'description': service.description ?? '',
                'hargaMulai': AppConstants.formatCurrency(service.price),
                'estimasi': '${service.estimatedDurationMinutes} menit'
              }),
        ),
      );
}

class _Error extends StatelessWidget {
  final String message;
  final VoidCallback retry;
  const _Error({required this.message, required this.retry});
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            const Text('Layanan gagal dimuat.'),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: retry, child: const Text('Coba lagi'))
          ])));
}
