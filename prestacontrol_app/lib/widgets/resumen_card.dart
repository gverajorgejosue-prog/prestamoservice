import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/resumen_model.dart';

class ResumenCard extends StatelessWidget {
  final ResumenModel resumen;
  final bool loading;

  const ResumenCard({super.key, required this.resumen, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);
    final scheme = Theme.of(context).colorScheme;

    Widget metric(String label, String value, IconData icon, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: scheme.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const SizedBox(height: 90, child: Center(child: CircularProgressIndicator()))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dashboard_rounded, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text('Resumen de cartera', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      metric('Capital prestado', currency.format(resumen.capitalPrestado), Icons.account_balance_wallet_outlined, Colors.blue),
                      const SizedBox(width: 10),
                      metric('Total por cobrar', currency.format(resumen.totalPorCobrar), Icons.payments_outlined, Colors.teal),
                      const SizedBox(width: 10),
                      metric('Ganancia esperada', currency.format(resumen.gananciaEsperada), Icons.trending_up_rounded, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pendientes: ${resumen.cantidadPendientes}  •  Cobrados: ${resumen.cantidadCobrados}',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}
