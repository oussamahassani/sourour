const mongoose = require('mongoose');

// Schéma pour un fournisseur
const fournisseurSchema = new mongoose.Schema({
    // Identifiant unique du fournisseur
    idF: { type: mongoose.Schema.Types.ObjectId, auto: true },
    
    // Nom du fournisseur
    nomF: { type: String, required: false },
    
    // Prénom du fournisseur
    prenomF: { type: String, required: false },
    
    // Nom de l'entreprise
    entreprise: { type: String, required: false },
    
    // Adresse du fournisseur
    adresse: { type: String },
    
    // Numéro de téléphone du fournisseur
    telephone: { type: String },
    
    // Email du fournisseur
    email: { type: String },
    
    // Matricule ou code d'enregistrement du fournisseur
    matricule: { type: String },
    
    // Date de création du fournisseur
    date_creation: { type: Date, default: Date.now },
    
    // Évaluation du fournisseur
    evaluation: { type: Number, min: 0, max: 5 },
    
    // Notes supplémentaires sur le fournisseur
    notes: { type: String },
    
    // Conditions de paiement du fournisseur
    conditions_paiement: { type: String },
    
    // Délai moyen de livraison en jours
    delai_livraison_moyen: { type: Number }
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.model('fournisseur', fournisseurSchema);