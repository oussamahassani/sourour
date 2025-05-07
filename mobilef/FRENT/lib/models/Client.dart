class Client {
  final String id;
  final String nom;
  final String prenom;

  Client({required this.id, required this.nom, required this.prenom});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['_id'],
      nom: json['nom'],
      prenom: json['prenom'],
    );
  }

  String get fullName => '$nom $prenom';

  @override
  String toString() => fullName; // Optional: display label
}
