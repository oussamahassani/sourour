const mongoose = require('mongoose');

// Schéma pour un employé
const EmployeeSchema = new mongoose.Schema({
    // Identifiant unique de l'employé
    id_employee: { type: mongoose.Schema.Types.ObjectId, auto: true },

    // Identifiant de l'utilisateur associé à l'employé (lié à un utilisateur dans un autre modèle)
    id_u: { type: mongoose.Schema.Types.ObjectId},

    // Nom complet de l'employé
    full_name: { type: String, required: true },

    // Département de l'employé
    department: { type: String, required: true },

    // Date d'embauche de l'employé
    date_hire: { type: Date},

    // Salaire de l'employé
    salary: { type: Number, required: true },

    // Type de contrat de l'employé (CDI, CDD, etc.)
    type_contrat: { type: String, required: true },

    // Date de fin du contrat, s'il s'agit d'un CDD
    date_fin_contrat: { type: Date },

    // Nombre de jours de congés restants
    jours_conges_restants: { type: Number, default: 0 },

    // Date de la dernière évaluation de l'employé
    derniere_evaluation: { type: Date },

    // Note de l'évaluation
    note_evaluation: { type: Number, min: 0, max: 10 },

    // Observations concernant l'employé
    observations: { type: String },

    // Adresse de l'employé
    adresse: { type: String, required: true },

    // Numéro de sécurité sociale de l'employé
    num_securite_sociale: { type: String}
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.model('Employee', EmployeeSchema);
