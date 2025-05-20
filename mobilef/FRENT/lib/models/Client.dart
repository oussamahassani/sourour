class Client {
  final String id;
  final String nom;
  final String prenom;
  final String adresse;

  Client({
    required this.id,
    required this.adresse,
    required this.nom,
    required this.prenom,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['_id'],
      nom: json['nom'],
      prenom: json['prenom'],
      adresse: json['adresse'],
    );
  }

  String get fullName => '$nom $prenom';

  @override
  String toString() => fullName; // Optional: display label
}
