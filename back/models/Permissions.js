const mongoose = require('mongoose');

// Schéma pour une permission
const PermissionSchema = new mongoose.Schema({
    // Identifiant unique de la permission
    id_permission: { type: mongoose.Schema.Types.ObjectId, auto: true },

    // Nom de la permission
    permission_name: { type: String, required: true },

    // Description de la permission
    description: { type: String },

    // Module auquel la permission appartient (par exemple : utilisateurs, paiement, etc.)
    module: { type: String, required: true },

    // Niveau d'accès associé à la permission (par exemple : admin, utilisateur, modérateur, etc.)
    niveau_acces: { type: String, required: true }
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.model('Permission', PermissionSchema);
