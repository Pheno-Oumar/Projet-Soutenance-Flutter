class LoginRequest {
  final String identifiant; // Téléphone ou Email
  final String motDePasse;

  const LoginRequest({
    required this.identifiant,
    required this.motDePasse,
  });

  Map<String, dynamic> toJson() {
    final clean = identifiant.trim();
    final isEmail = clean.contains('@');

    return {
      // Formats acceptés par Spring Boot (LoginRequestDTO)
      if (isEmail) 'email': clean else 'telephone': clean,
      'password': motDePasse,
      // Alias pour compatibilité
      'identifiant': clean,
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
  final String? slugSalon;
  final String? nomSalon;
  final String? logoUrl;

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
    this.slugSalon,
    this.nomSalon,
    this.logoUrl,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Dans Spring Boot (LoginResponseDTO), les infos du compte sont imbriquées dans `compte`
    final compte = json['compte'] as Map<String, dynamic>?;

    final id = (compte?['id'] as num?)?.toInt() ??
        (json['userId'] as num?)?.toInt() ??
        (json['id'] as num?)?.toInt() ??
        0;

    final nom = compte?['nom'] as String? ?? json['nom'] as String?;
    final prenom = compte?['prenom'] as String? ?? json['prenom'] as String?;
    final email = compte?['email'] as String? ?? json['email'] as String?;
    final telephone = compte?['telephone'] as String? ?? json['telephone'] as String?;
    final role = compte?['rolePlateforme'] as String? ??
        (json['rolesSalon'] is List && (json['rolesSalon'] as List).isNotEmpty
            ? (json['rolesSalon'] as List).first.toString()
            : json['role'] as String? ?? 'CLIENT');

    return AuthResponse(
      accessToken: json['accessToken'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      userId: id,
      role: role,
      email: email,
      telephone: telephone,
      nom: nom,
      prenom: prenom,
      slugSalon: json['slugSalon'] as String?,
      nomSalon: json['nomSalon'] as String?,
      logoUrl: json['logoUrl'] as String?,
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
    this.codePays = 'Mali',
    this.email,
    required this.motDePasse,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'prenom': prenom.trim(),
      'nom': nom.trim(),
      'telephone': telephone.trim(),
      'pays': codePays,
      'password': motDePasse, // Attendu par Spring Boot ClientRegisterDTORequest
      'motDePasse': motDePasse, // Alias
    };
    if (email != null && email!.trim().isNotEmpty) {
      map['email'] = email!.trim();
    }
    return map;
  }
}
