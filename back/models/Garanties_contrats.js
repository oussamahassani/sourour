const mongoose = require('mongoose');

// Schéma pour une garantie
const GarantieSchema = new mongoose.Schema({
    // Identifiant unique de la garantie
    id_garantie: { type: mongoose.Schema.Types.ObjectId, auto: true },
    
    // Identifiant de la vente associée
    id_vente: { type: mongoose.Schema.Types.ObjectId, required: true },
    
    // Identifiant de l'article concerné
    id_article: { type: mongoose.Schema.Types.ObjectId, required: true },
    
    // Identifiant du client
    id_client: { type: mongoose.Schema.Types.ObjectId, required: true },
    
    // Date de début de la garantie
    date_debut: { type: Date, required: true },
    
    // Date de fin de la garantie
    date_fin: { type: Date, required: true },
    
    // Type de garantie
    type: { type: String, required: true },
    
    // Description de la garantie
    description: { type: String },
    
    // Intervalle de maintenance en jours
    intervalle_maintenance: { type: Number },
    
    // Prochaine date de maintenance
    prochaine_maintenance: { type: Date },
    
    // Conditions de la garantie
    conditions: { type: String }
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.model('Garantie', GarantieSchema);
