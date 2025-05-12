class Fournisseur {
  final String? id;
  final String type; // 'Entreprise' ou 'Personne'
  final String? nom;
  final String? prenom;
  final String? entreprise;
  final String? matricule;
  final String adresse;
  final String email;
  final String telephone;
  final int evaluation; // 0-10
  final int delaiLivraisonMoyen; // en jours
  final String? conditionsPaiement;
  final String? notes;
  final DateTime dateCreation;

  Fournisseur({
    this.id,
    required this.type,
    this.nom,
    this.prenom,
    this.entreprise,
    this.matricule,
    required this.adresse,
    required this.email,
    required this.telephone,
    this.evaluation = 0,
    this.delaiLivraisonMoyen = 0,
    this.conditionsPaiement,
    this.notes,
    required this.dateCreation,
  }) {
    // Validations améliorées
    if (type != 'Entreprise' && type != 'Personne') {
      throw ArgumentError("Le type doit être 'Entreprise' ou 'Personne'");
    }
    if (evaluation < 0 || evaluation > 10) {
      throw ArgumentError("L'évaluation doit être entre 0 et 10");
    }
    if (delaiLivraisonMoyen < 0) {
      throw ArgumentError("Le délai de livraison ne peut pas être négatif");
    }
    if (email.isEmpty || !email.contains('@')) {
      throw ArgumentError("Email invalide");
    }
  }

  factory Fournisseur.fromJson(Map<String, dynamic> json) {
    try {
      return Fournisseur(
        id: json['_id']?.toString(),
        type: json['type']?.toString() ?? 'Personne',
        nom: json['nomF']?.toString(),
        prenom: json['prenomF']?.toString(),
        entreprise: json['entreprise']?.toString(),
        matricule: json['matricule']?.toString(),
        adresse: json['adresse']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        telephone: json['telephone']?.toString() ?? '',
        evaluation: (json['evaluation'] as num?)?.toInt() ?? 0,
        delaiLivraisonMoyen:
            (json['delaiLivraisonMoyen'] as num?)?.toInt() ?? 0,
        conditionsPaiement: json['conditionsPaiement']?.toString(),
        notes: json['notes']?.toString(),
        dateCreation: DateTime.parse(
          json['dateCreation']?.toString() ?? DateTime.now().toIso8601String(),
        ),
      );
    } catch (e) {
      throw FormatException(
        "Erreur lors de la conversion JSON en Fournisseur: ${e.toString()}",
      );
    }
  }

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'type': type,
    'nomF': nom,
    'prenomF': prenom,
    'entreprise': entreprise,
    'matricule': matricule,
    'adresse': adresse,
    'email': email,
    'telephone': telephone,
    'evaluation': evaluation,
    'delaiLivraisonMoyen': delaiLivraisonMoyen,
    'conditionsPaiement': conditionsPaiement,
    'notes': notes,
    'dateCreation': dateCreation.toIso8601String(),
  };

  String get displayName =>
      type == 'Entreprise'
          ? entreprise?.isNotEmpty == true
              ? entreprise!
              : 'Nom d\'entreprise non spécifié'
          : [
            prenom?.trim(),
            nom?.trim(),
          ].where((n) => n?.isNotEmpty == true).join(' ').trim();

  bool get isEntreprise => type == 'Entreprise';

  Fournisseur copyWith({
    String? id,
    String? type,
    String? nom,
    String? prenom,
    String? entreprise,
    String? matricule,
    String? adresse,
    String? email,
    String? telephone,
    int? evaluation,
    int? delaiLivraisonMoyen,
    String? conditionsPaiement,
    String? notes,
    DateTime? dateCreation,
  }) {
    return Fournisseur(
      id: id ?? this.id,
      type: type ?? this.type,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      entreprise: entreprise ?? this.entreprise,
      matricule: matricule ?? this.matricule,
      adresse: adresse ?? this.adresse,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      evaluation: evaluation ?? this.evaluation,
      delaiLivraisonMoyen: delaiLivraisonMoyen ?? this.delaiLivraisonMoyen,
      conditionsPaiement: conditionsPaiement ?? this.conditionsPaiement,
      notes: notes ?? this.notes,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fournisseur &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          nom == other.nom &&
          prenom == other.prenom &&
          entreprise == other.entreprise &&
          matricule == other.matricule &&
          adresse == other.adresse &&
          email == other.email &&
          telephone == other.telephone &&
          evaluation == other.evaluation &&
          delaiLivraisonMoyen == other.delaiLivraisonMoyen &&
          conditionsPaiement == other.conditionsPaiement &&
          notes == other.notes &&
          dateCreation == other.dateCreation;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      nom.hashCode ^
      prenom.hashCode ^
      entreprise.hashCode ^
      matricule.hashCode ^
      adresse.hashCode ^
      email.hashCode ^
      telephone.hashCode ^
      evaluation.hashCode ^
      delaiLivraisonMoyen.hashCode ^
      conditionsPaiement.hashCode ^
      notes.hashCode ^
      dateCreation.hashCode;

  get nomEntreprise => null;

  get idFournisseur => null;

  get nomFournisseur => null;

  get codeFournisseur => null;

  get typeFournisseur => null;

  // Méthode pour éviter les NoSuchMethodError
  dynamic safeGet(String property) {
    switch (property) {
      case 'id':
        return id;
      case 'type':
        return type;
      case 'nom':
        return nom;
      case 'prenom':
        return prenom;
      case 'entreprise':
        return entreprise;
      case 'matricule':
        return matricule;
      case 'adresse':
        return adresse;
      case 'email':
        return email;
      case 'telephone':
        return telephone;
      case 'evaluation':
        return evaluation;
      case 'delaiLivraisonMoyen':
        return delaiLivraisonMoyen;
      case 'conditionsPaiement':
        return conditionsPaiement;
      case 'notes':
        return notes;
      case 'dateCreation':
        return dateCreation;
      default:
        throw ArgumentError('Propriété non reconnue: $property');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'entreprise': entreprise,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'matricule': matricule,
      'evaluation': evaluation,
      'delaiLivraisonMoyen': delaiLivraisonMoyen,
      'conditionsPaiement': conditionsPaiement,
      'notes': notes,
      // Ajoutez toutes les autres propriétés nécessaires
    };
  }
}
