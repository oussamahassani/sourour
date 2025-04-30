const mongoose = require('mongoose');

// Schéma pour un audit
const AuditSchema = new mongoose.Schema({
    // Identifiant unique de l'audit
    id_audit: { type: mongoose.Schema.Types.ObjectId, auto: true },
    
    // Identifiant de l'utilisateur ayant effectué l'action
    id_utilisateur: { type: mongoose.Schema.Types.ObjectId, required: true },
    
    // Type d'action effectuée (INSERT, UPDATE, DELETE)
    action: { type: String, required: true },
    
    // Nom de la table concernée
    table_concernee: { type: String, required: true },
    
    // Identifiant de l'enregistrement affecté
    id_enregistrement: { type: mongoose.Schema.Types.ObjectId, required: true },
    
    // Ancienne valeur avant modification
    ancienne_valeur: { type: mongoose.Schema.Types.Mixed },
    
    // Nouvelle valeur après modification
    nouvelle_valeur: { type: mongoose.Schema.Types.Mixed },
    
    // Adresse IP de l'utilisateur ayant effectué l'action
    adresse_ip: { type: String, required: true },
    
    // Date et heure de l'action
    date_action: { type: Date, default: Date.now }
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.model('Audit', AuditSchema);
