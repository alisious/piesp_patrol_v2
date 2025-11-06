import 'package:flutter/material.dart';

class DutyTab extends StatelessWidget {
  const DutyTab({super.key, this.unitName});
  final String? unitName;

  @override
 Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_moon_outlined, size: 64),
          const SizedBox(height: 16),
          Text(
            (unitName != null && unitName!.isNotEmpty)
                ? 'Jednostka: $unitName'
                : 'Zakładka: Służba',
          ),
        ],
      ),
    ),
      ),
    );
  }
}
