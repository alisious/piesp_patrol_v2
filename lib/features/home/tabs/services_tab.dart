import 'package:flutter/material.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key, required this.baseUrl});
  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_document, size: 64),
          const SizedBox(height: 16),
          const Text('Zakładka: Usługi'),
          const SizedBox(height: 8),
          Text('Endpoint: $baseUrl', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
