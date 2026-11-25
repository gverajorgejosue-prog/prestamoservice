import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/prestamo_model.dart';
import '../services/api_client.dart';
import '../services/prestamo_service.dart';
import '../services/storage_service.dart';

class PrestamoFormScreen extends StatefulWidget {
  final PrestamoModel? prestamo;
  const PrestamoFormScreen({super.key, this.prestamo});

  @override
  State<PrestamoFormScreen> createState() => _PrestamoFormScreenState();
}

class _PrestamoFormScreenState extends State<PrestamoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clienteCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _interesCtrl = TextEditingController();
  DateTime? _fechaVencimiento;
  bool _pagado = false;
  bool _saving = false;

  late final PrestamoService _prestamoService = PrestamoService(ApiClient(StorageService()));

  bool get isEdit => widget.prestamo != null;

  @override
  void initState() {
    super.initState();
    final p = widget.prestamo;
    if (p != null) {
      _clienteCtrl.text = p.cliente;
      _dniCtrl.text = p.dni;
      _montoCtrl.text = p.monto.toStringAsFixed(2);
      _interesCtrl.text = p.interes.toStringAsFixed(2);
      _fechaVencimiento = p.fechaVencimiento;
      _pagado = p.pagado;
    }
  }

  @override
  void dispose() {
    _clienteCtrl.dispose();
    _dniCtrl.dispose();
    _montoCtrl.dispose();
    _interesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _fechaVencimiento ?? now.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
      helpText: 'Selecciona fecha de vencimiento',
    );
    if (picked != null) {
      setState(() => _fechaVencimiento = picked);
    }
  }

  double? _parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '.').trim());
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaVencimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona la fecha de vencimiento')));
      return;
    }
    setState(() => _saving = true);
    final prestamo = PrestamoModel(
      id: widget.prestamo?.id,
      cliente: _clienteCtrl.text.trim(),
      dni: _dniCtrl.text.trim(),
      monto: _parseDouble(_montoCtrl.text) ?? 0,
      interes: _parseDouble(_interesCtrl.text) ?? 0,
      totalCobrar: 0,
      fechaPrestamo: widget.prestamo?.fechaPrestamo,
      fechaVencimiento: _fechaVencimiento!,
      pagado: _pagado,
    );

    try {
      if (isEdit) {
        await _prestamoService.updatePrestamo(widget.prestamo!.id!, prestamo);
      } else {
        await _prestamoService.createPrestamo(prestamo);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException ? e.message : 'No se pudo guardar el préstamo';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy', 'es');
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar préstamo' : 'Nuevo préstamo')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _clienteCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Cliente', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'El cliente es obligatorio';
                    if (value.length > 100) return 'Máximo 100 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dniCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                  decoration: const InputDecoration(labelText: 'DNI', prefixIcon: Icon(Icons.badge_outlined)),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'El DNI es obligatorio';
                    if (!RegExp(r'^\d{8}$').hasMatch(value)) return 'El DNI debe tener 8 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _montoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Monto (S/)', prefixIcon: Icon(Icons.attach_money)),
                  validator: (v) {
                    final value = _parseDouble(v ?? '');
                    if (value == null) return 'Ingresa un monto válido';
                    if (value <= 0) return 'El monto debe ser mayor a 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _interesCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Interés (%)', prefixIcon: Icon(Icons.percent)),
                  validator: (v) {
                    final value = _parseDouble(v ?? '');
                    if (value == null) return 'Ingresa un interés válido';
                    if (value < 0) return 'El interés no puede ser negativo';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de vencimiento',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      _fechaVencimiento == null ? 'Seleccionar fecha' : fmt.format(_fechaVencimiento!),
                      style: TextStyle(color: _fechaVencimiento == null ? Colors.grey.shade600 : Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Marcar como pagado'),
                  value: _pagado,
                  onChanged: (v) => setState(() => _pagado = v),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(isEdit ? 'Guardar cambios' : 'Crear préstamo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
