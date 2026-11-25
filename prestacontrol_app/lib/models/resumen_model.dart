class ResumenModel {
  final double capitalPrestado;
  final double totalPorCobrar;
  final double gananciaEsperada;
  final int cantidadPendientes;
  final int cantidadCobrados;

  ResumenModel({
    required this.capitalPrestado,
    required this.totalPorCobrar,
    required this.gananciaEsperada,
    required this.cantidadPendientes,
    required this.cantidadCobrados,
  });

  factory ResumenModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '0') ?? 0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '0') ?? 0;
    }

    return ResumenModel(
      capitalPrestado: parseDouble(json['capitalPrestado']),
      totalPorCobrar: parseDouble(json['totalPorCobrar']),
      gananciaEsperada: parseDouble(json['gananciaEsperada']),
      cantidadPendientes: parseInt(json['cantidadPendientes']),
      cantidadCobrados: parseInt(json['cantidadCobrados']),
    );
  }

  Map<String, dynamic> toJson() => {
        'capitalPrestado': capitalPrestado,
        'totalPorCobrar': totalPorCobrar,
        'gananciaEsperada': gananciaEsperada,
        'cantidadPendientes': cantidadPendientes,
        'cantidadCobrados': cantidadCobrados,
      };

  factory ResumenModel.empty() => ResumenModel(
        capitalPrestado: 0,
        totalPorCobrar: 0,
        gananciaEsperada: 0,
        cantidadPendientes: 0,
        cantidadCobrados: 0,
      );
}
