class User {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '', // Adapté pour MongoDB
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      telephone: json['telephone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'nom': nom, 'prenom': prenom, 'telephone': telephone};
  }
}
