class PrestamoModel {
  final int? id;
  final String cliente;
  final String dni;
  final double monto;
  final double interes;
  final double totalCobrar;
  final DateTime? fechaPrestamo;
  final DateTime fechaVencimiento;
  final bool pagado;

  PrestamoModel({
    this.id,
    required this.cliente,
    required this.dni,
    required this.monto,
    required this.interes,
    required this.totalCobrar,
    required this.fechaPrestamo,
    required this.fechaVencimiento,
    required this.pagado,
  });

  factory PrestamoModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '0') ?? 0;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return PrestamoModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      cliente: json['cliente']?.toString() ?? '',
      dni: json['dni']?.toString() ?? '',
      monto: parseDouble(json['monto']),
      interes: parseDouble(json['interes']),
      totalCobrar: parseDouble(json['totalCobrar']),
      fechaPrestamo: parseDate(json['fechaPrestamo']),
      fechaVencimiento: parseDate(json['fechaVencimiento']) ?? DateTime.now(),
      pagado: json['pagado'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'cliente': cliente,
        'dni': dni,
        'monto': monto,
        'interes': interes,
        'fechaVencimiento': fechaVencimiento.toIso8601String().split('T').first,
        'pagado': pagado,
      };

  bool get isVencido {
    if (pagado) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(fechaVencimiento.year, fechaVencimiento.month, fechaVencimiento.day);
    return due.isBefore(today);
  }

  PrestamoModel copyWith({
    int? id,
    String? cliente,
    String? dni,
    double? monto,
    double? interes,
    double? totalCobrar,
    DateTime? fechaPrestamo,
    DateTime? fechaVencimiento,
    bool? pagado,
  }) {
    return PrestamoModel(
      id: id ?? this.id,
      cliente: cliente ?? this.cliente,
      dni: dni ?? this.dni,
      monto: monto ?? this.monto,
      interes: interes ?? this.interes,
      totalCobrar: totalCobrar ?? this.totalCobrar,
      fechaPrestamo: fechaPrestamo ?? this.fechaPrestamo,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      pagado: pagado ?? this.pagado,
    );
  }
}
