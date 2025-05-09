class Employee {
  final String? id;
  final String? fullname;
  final String? prenom;
  final int? age;
  final String? telephone;
  final String? adresse;
  final String? email;
  final String? dateEmbauche;
  final String? genre;
  final String? situationFamiliale;
  final String? poste;
  final String? privilege;
  final String? numSecuriteSociale;
  final String? observations;
  final String? noteEvaluation;
  final String? derniereEvaluation;
  final String? joursCongesRestants;
  final String? dateFinContrat;
  final String? typeContrat;
  final String? salary;
  final String? dateHire;
  final String? department;

  Employee({
    this.id,
    this.fullname,
    this.prenom,
    this.age,
    this.telephone,
    this.adresse,
    this.email,
    this.dateEmbauche,
    this.genre,
    this.situationFamiliale,
    this.poste,
    this.privilege,
    this.numSecuriteSociale,
    this.observations,
    this.noteEvaluation,
    this.derniereEvaluation,
    this.joursCongesRestants,
    this.dateFinContrat,
    this.typeContrat,
    this.salary,
    this.dateHire,
    this.department,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'] as String?,
      fullname: json['full_name'] as String?,
      prenom: json['prenom'] as String?,
      age: json['age'] as int?,
      telephone: json['telephone'] as String?,
      adresse: json['adresse'] as String?,
      email: json['email'] as String?,
      dateEmbauche: json['dateEmbauche'] as String?,
      genre: json['genre'] as String?,
      situationFamiliale: json['situation_familiale'] as String?,
      poste: json['poste'] as String?,
      privilege: json['privilege'] as String?,
      numSecuriteSociale: json['num_securite_sociale'] as String?,
      observations: json['observations'] as String?,
      noteEvaluation: json['note_evaluation']?.toString(),
      derniereEvaluation: json['derniere_evaluation'] as String?,
      joursCongesRestants: json['jours_conges_restants']?.toString(),
      dateFinContrat: json['date_fin_contrat'] as String?,
      typeContrat: json['type_contrat'] as String?,
      salary: json['salary']?.toString(),
      dateHire: json['date_hire'] as String?,
      department: json['department'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'full_name': fullname,
    'prenom': prenom,
    'num_securite_sociale': numSecuriteSociale,
    'department': "RH",
    'adresse': adresse,
    'email': email,
    'telephone': telephone,
    'joursCongesRestants': joursCongesRestants,
    'date_hire': dateHire,
    'genre': genre,
    'date_fin_contrat': dateFinContrat,
    'salary': 1000,
    'type_contrat': 'cdi',
  };
}
