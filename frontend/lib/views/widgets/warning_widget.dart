import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WarningWidget extends StatelessWidget {
  const WarningWidget({super.key, required this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error!,
              style: TextStyle(color: Colors.orange, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
