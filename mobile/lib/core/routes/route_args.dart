import 'package:flutter/material.dart';

class RouteArgs {
  RouteArgs._();

  static Map<String, dynamic>? map(BuildContext context) {
    final value = ModalRoute.of(context)?.settings.arguments;
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  static T? of<T>(BuildContext context) {
    final value = ModalRoute.of(context)?.settings.arguments;
    return value is T ? value : null;
  }
}

class MissingArgsScreen extends StatelessWidget {
  final String message;
  const MissingArgsScreen({super.key, this.message = 'Data tidak ditemukan'});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Data tidak tersedia')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 48),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali')),
              ],
            ),
          ),
        ),
      );
}
