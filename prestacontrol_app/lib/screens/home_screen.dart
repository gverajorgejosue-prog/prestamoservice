import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/prestamo_model.dart';
import '../models/resumen_model.dart';
import '../models/usuario_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/prestamo_service.dart';
import '../services/storage_service.dart';
import '../widgets/prestamo_card.dart';
import '../widgets/resumen_card.dart';
import '../widgets/token_expiry_banner.dart';
import 'login_screen.dart';
import 'prestamo_form_screen.dart';

enum PrestamoFilter { todos, porCobrar, cobrados }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  late final ApiClient _client = ApiClient(_storage);
  late final AuthService _auth = AuthService(_client, _storage);
  late final PrestamoService _prestamoService = PrestamoService(_client);

  final _searchCtrl = TextEditingController();
  List<PrestamoModel> _prestamos = [];
  ResumenModel _resumen = ResumenModel.empty();
  UsuarioModel? _user;
  DateTime? _tokenExpiry;
  PrestamoFilter _filter = PrestamoFilter.todos;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _prestamoService.getPrestamos(),
        _prestamoService.getResumen(),
        _auth.getCurrentUser(),
        _auth.getTokenExpiry(),
      ]);
      if (!mounted) return;
      setState(() {
        _prestamos = results[0] as List<PrestamoModel>;
        _resumen = results[1] as ResumenModel;
        _user = results[2] as UsuarioModel?;
        _tokenExpiry = results[3] as DateTime?;
      });
    } catch (e) {
      if (!mounted) return;
      if (e is UnauthorizedException) return; // interceptor handles navigation
      setState(() => _error = e is ApiException ? e.message : 'No se pudo cargar la información');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<PrestamoModel> get _filteredPrestamos {
    final query = _searchCtrl.text.trim().toLowerCase();
    return _prestamos.where((p) {
      final matchesFilter = switch (_filter) {
        PrestamoFilter.todos => true,
        PrestamoFilter.porCobrar => !p.pagado,
        PrestamoFilter.cobrados => p.pagado,
      };
      final matchesQuery = query.isEmpty ||
          p.cliente.toLowerCase().contains(query) ||
          p.dni.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _openForm({PrestamoModel? prestamo}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PrestamoFormScreen(prestamo: prestamo)),
    );
    if (changed == true) {
      await _loadAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(prestamo == null ? 'Préstamo creado' : 'Préstamo actualizado')),
        );
      }
    }
  }

  Future<void> _togglePagado(PrestamoModel p) async {
    final action = p.pagado ? 'marcar como pendiente' : 'marcar como cobrado';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar acción'),
        content: Text('¿Deseas $action el préstamo de ${p.cliente}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final updated = p.copyWith(pagado: !p.pagado);
      await _prestamoService.updatePrestamo(p.id!, updated);
      await _loadAll();
    } catch (e) {
      if (!mounted) return;
      if (e is UnauthorizedException) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : 'No se pudo actualizar el préstamo')),
      );
    }
  }

  Future<void> _delete(PrestamoModel p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar préstamo'),
        content: Text('¿Seguro que deseas eliminar el préstamo de ${p.cliente}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(foregroundColor: Colors.red.shade800),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _prestamoService.deletePrestamo(p.id!);
      await _loadAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Préstamo eliminado')));
      }
    } catch (e) {
      if (!mounted) return;
      if (e is UnauthorizedException) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : 'No se pudo eliminar el préstamo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPrestamos;
    final currency = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PrestaControl', style: TextStyle(fontWeight: FontWeight.w700)),
            if (_user != null)
              Text(_user!.nombre, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(onPressed: _loading ? null : _loadAll, icon: const Icon(Icons.refresh), tooltip: 'Actualizar'),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout), tooltip: 'Cerrar sesión'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo préstamo'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAll,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            children: [
              TokenExpiryBanner(expiry: _tokenExpiry),
              ResumenCard(resumen: _resumen, loading: _loading && _prestamos.isEmpty),
              const SizedBox(height: 12),
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Buscar por cliente o DNI',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: _searchCtrl.clear)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<PrestamoFilter>(
                segments: const [
                  ButtonSegment(value: PrestamoFilter.todos, label: Text('Todos'), icon: Icon(Icons.list_alt)),
                  ButtonSegment(value: PrestamoFilter.porCobrar, label: Text('Por cobrar'), icon: Icon(Icons.schedule)),
                  ButtonSegment(value: PrestamoFilter.cobrados, label: Text('Cobrados'), icon: Icon(Icons.check_circle_outline)),
                ],
                selected: {_filter},
                onSelectionChanged: (s) => setState(() => _filter = s.first),
              ),
              const SizedBox(height: 12),
              if (_loading && _prestamos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 36),
                        const SizedBox(height: 8),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        FilledButton.tonal(onPressed: _loadAll, child: const Text('Reintentar')),
                      ],
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 44, color: Colors.grey.shade500),
                        const SizedBox(height: 8),
                        Text(
                          _prestamos.isEmpty ? 'Aún no tienes préstamos registrados' : 'No hay resultados para el filtro/búsqueda',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    '${filtered.length} préstamo(s) • Total mostrado: ${currency.format(filtered.fold<double>(0, (sum, p) => sum + p.totalCobrar))}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                ),
                ...filtered.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PrestamoCard(
                        prestamo: p,
                        onEdit: () => _openForm(prestamo: p),
                        onDelete: () => _delete(p),
                        onTogglePagado: () => _togglePagado(p),
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
