import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TokenExpiryBanner extends StatelessWidget {
  final DateTime? expiry;
  const TokenExpiryBanner({super.key, required this.expiry});

  @override
  Widget build(BuildContext context) {
    if (expiry == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final remaining = expiry!.difference(now);
    if (remaining.isNegative) return const SizedBox.shrink();

    final lessThanHour = remaining.inMinutes < 60;
    final bg = lessThanHour ? Colors.orange.shade50 : Colors.blue.shade50;
    final border = lessThanHour ? Colors.orange.shade300 : Colors.blue.shade200;
    final fg = lessThanHour ? Colors.orange.shade900 : Colors.blue.shade900;
    final icon = lessThanHour ? Icons.warning_amber_rounded : Icons.schedule_rounded;
    final fmt = DateFormat('dd/MM/yyyy HH:mm', 'es');
    final label = lessThanHour
        ? 'Tu sesión expira pronto (${remaining.inMinutes} min). Vence: ${fmt.format(expiry!.toLocal())}'
        : 'Sesión expira: ${fmt.format(expiry!.toLocal())}';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
