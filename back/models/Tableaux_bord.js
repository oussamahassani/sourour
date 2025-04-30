const mongoose = require('mongoose');

// Schéma pour un tableau
const TableauSchema = new mongoose.Schema({
    // Identifiant unique du tableau
    id_tableau: { type: mongoose.Schema.Types.ObjectId, auto: true },

    // Titre du tableau
    titre: { type: String, required: true },

    // Identifiant de l'utilisateur associé au tableau
    id_utilisateur: { type: mongoose.Schema.Types.ObjectId, required: true },

    // Configuration du tableau (par exemple, options de présentation ou de données)
    configuration: { type: mongoose.Schema.Types.Mixed, required: true },

    // Date de création du tableau
    date_creation: { type: Date, default: Date.now },

    // Date de la dernière modification du tableau
    derniere_modification: { type: Date, default: Date.now }
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.model('Tableau', TableauSchema);
