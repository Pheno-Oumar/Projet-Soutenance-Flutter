class LoginRequest {
  final String identifiant; // Téléphone ou Email
  final String motDePasse;

  const LoginRequest({
    required this.identifiant,
    required this.motDePasse,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifiant': identifiant,
      'motDePasse': motDePasse,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int userId;
  final String role;
  final String? email;
  final String? telephone;
  final String? nom;
  final String? prenom;

  const AuthResponse({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    required this.userId,
    required this.role,
    this.email,
    this.telephone,
    this.nom,
    this.prenom,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      userId: json['userId'] as int? ?? json['id'] as int? ?? 0,
      role: json['role'] as String? ?? 'CLIENT',
      email: json['email'] as String?,
      telephone: json['telephone'] as String?,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
    );
  }
}

class RegisterRequest {
  final String prenom;
  final String nom;
  final String telephone;
  final String codePays;
  final String? email;
  final String motDePasse;

  const RegisterRequest({
    required this.prenom,
    required this.nom,
    required this.telephone,
    this.codePays = 'SN',
    this.email,
    required this.motDePasse,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'prenom': prenom,
      'nom': nom,
      'telephone': telephone,
      'codePays': codePays,
      'motDePasse': motDePasse,
    };
    if (email != null && email!.isNotEmpty) {
      map['email'] = email;
    }
    return map;
  }
}
