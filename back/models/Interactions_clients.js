const mongoose = require('mongoose');

// Schéma pour une interaction client
const InteractionSchema = new mongoose.Schema({
    // Identifiant unique de l'interaction
    id_interaction: { type: mongoose.Schema.Types.ObjectId, auto: true },
    
    // Identifiant du client concerné
    id_client: { type: mongoose.Schema.Types.ObjectId, required: true },
    
    // Identifiant de l'utilisateur qui a effectué l'interaction
    id_utilisateur: { type: mongoose.Schema.Types.ObjectId, required: true },
    
    // Date de l'interaction
    date_interaction: { type: Date, required: true },
    
    // Type d'interaction (appel, email, réunion, etc.)
    type_interaction: { type: String, required: true },
    
    // Description de l'interaction
    description: { type: String },
    
    // Indicateur si un suivi est requis
    suivi_requis: { type: Boolean, default: false },
    
    // Date prévue pour le suivi
    date_suivi: { type: Date }
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.model('Interaction', InteractionSchema);
