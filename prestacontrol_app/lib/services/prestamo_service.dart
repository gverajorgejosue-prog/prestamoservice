import '../models/prestamo_model.dart';
import '../models/resumen_model.dart';
import 'api_client.dart';

class PrestamoService {
  final ApiClient _client;
  PrestamoService(this._client);

  Future<List<PrestamoModel>> getPrestamos() async {
    final data = await _client.get('/prestamos') as List<dynamic>;
    return data.map((e) => PrestamoModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PrestamoModel> getPrestamo(int id) async {
    final data = await _client.get('/prestamos/$id') as Map<String, dynamic>;
    return PrestamoModel.fromJson(data);
  }

  Future<PrestamoModel> createPrestamo(PrestamoModel prestamo) async {
    final data = await _client.post('/prestamos', body: prestamo.toJson()) as Map<String, dynamic>;
    return PrestamoModel.fromJson(data);
  }

  Future<PrestamoModel> updatePrestamo(int id, PrestamoModel prestamo) async {
    final data = await _client.put('/prestamos/$id', body: prestamo.toJson()) as Map<String, dynamic>;
    return PrestamoModel.fromJson(data);
  }

  Future<void> deletePrestamo(int id) async {
    await _client.delete('/prestamos/$id');
  }

  Future<ResumenModel> getResumen() async {
    final data = await _client.get('/prestamos/resumen') as Map<String, dynamic>;
    return ResumenModel.fromJson(data);
  }
}
