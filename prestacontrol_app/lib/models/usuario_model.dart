class UsuarioModel {
  final String email;
  final String nombre;

  UsuarioModel({required this.email, required this.nombre});

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      email: json['email']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'nombre': nombre,
      };
}
