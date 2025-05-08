class Employee {
  final String id;
  final String fullName;
  final String department;
  final String dateHire;
  final double salary;
  final String typeContrat;
  final String? dateFinContrat;
  final int joursCongesRestants;
  final String? derniereEvaluation;
  final double? noteEvaluation;
  final String? observations;
  final String adresse;
  final String numSecuriteSociale;

  Employee({
    required this.id,
    required this.fullName,
    required this.department,
    required this.dateHire,
    required this.salary,
    required this.typeContrat,
    this.dateFinContrat,
    required this.joursCongesRestants,
    this.derniereEvaluation,
    this.noteEvaluation,
    this.observations,
    required this.adresse,
    required this.numSecuriteSociale,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'],
      fullName: json['full_name'],
      department: json['department'],
      dateHire: json['date_hire'],
      salary: json['salary'].toDouble(),
      typeContrat: json['type_contrat'],
      dateFinContrat: json['date_fin_contrat'],
      joursCongesRestants: json['jours_conges_restants'] ?? 0,
      derniereEvaluation: json['derniere_evaluation'],
      noteEvaluation: json['note_evaluation']?.toDouble(),
      observations: json['observations'],
      adresse: json['adresse'],
      numSecuriteSociale: json['num_securite_sociale'],
    );
  }
}
