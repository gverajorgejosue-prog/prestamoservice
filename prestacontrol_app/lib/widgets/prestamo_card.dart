import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/prestamo_model.dart';

class PrestamoCard extends StatelessWidget {
  final PrestamoModel prestamo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePagado;

  const PrestamoCard({
    super.key,
    required this.prestamo,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePagado,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);
    final dateFmt = DateFormat('dd/MM/yyyy', 'es');
    final vencido = prestamo.isVencido;
    final scheme = Theme.of(context).colorScheme;
    final cardColor = vencido ? Colors.red.shade50 : Colors.white;
    final borderColor = vencido ? Colors.red.shade300 : Colors.grey.shade200;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prestamo.cliente, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('DNI: ${prestamo.dni}', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                ),
                if (vencido)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(20)),
                    child: Text('VENCIDO', style: TextStyle(color: Colors.red.shade800, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                if (prestamo.pagado)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
                    child: Text('COBRADO', style: TextStyle(color: Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _info('Monto', currency.format(prestamo.monto)),
                _info('Interés', '${prestamo.interes.toStringAsFixed(2)}%'),
                _info('Total a cobrar', currency.format(prestamo.totalCobrar), highlight: true),
                _info('Vence', dateFmt.format(prestamo.fechaVencimiento)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTogglePagado,
                    icon: Icon(prestamo.pagado ? Icons.undo_rounded : Icons.check_circle_outline, size: 18),
                    label: Text(prestamo.pagado ? 'Marcar pendiente' : 'Marcar cobrado'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined), tooltip: 'Editar'),
                IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline), tooltip: 'Eliminar', color: Colors.red.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
            color: highlight ? Colors.teal.shade800 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
