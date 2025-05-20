const mongoose = require('mongoose');

// Schéma pour une intervention
const InterventionSchema = new mongoose.Schema({
    // Identifiant unique de l'intervention
    idI: { type: mongoose.Schema.Types.ObjectId, auto: true },
    
    // Identifiant du plan de maintenance ou de l'ordre de travail
    idPL: { type: mongoose.Schema.Types.ObjectId },
    
    // Date de l'intervention
    date_intervention: { type: Date, required: true },
    
    // Description de l'intervention
    description: { type: String },
    referenceNumber: { type: String },
    // Statut de l'intervention (en cours, terminé, annulé, etc.)
    statut: { type: String},
    
    // Rapport détaillé de l'intervention
    rapport_intervention: { type: String }, 
    
    // Durée réelle de l'intervention en heures
    duree_reelle: { type: Number },
    
    // Identifiant du technicien ayant effectué l'intervention
    id_technicien: { type: mongoose.Schema.Types.ObjectId },
    technicianName: { type: String },
    technicianAddress: { type: String },
    actualDuration: { type: String },
    estimatedDuration: { type: String },
    interventionType: { type: String },
    contactPerson: { type: String },
    clientName: { type: String },
    address: { type: String },

    // Signature du client en confirmation de l'intervention
    signature_client: { type: String },
    
    // Commentaires du client après l'intervention
    commentaires_client: { type: String }
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.model('Intervention', InterventionSchema);
