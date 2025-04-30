const mongoose = require('mongoose');

// Schéma pour une notification
const NotificationSchema = new mongoose.Schema({
    // Identifiant unique de la notification
    idN: { type: mongoose.Schema.Types.ObjectId, auto: true },
    
    // Identifiant de l'utilisateur concerné
    idU: { type: mongoose.Schema.Types.ObjectId, required: true },
    
    // Message de la notification
    message: { type: String, required: true },
    
    // Statut de la notification (lu, non lu)
    statut: { type: String, required: true },
    
    // URL de redirection après clic sur la notification
    url_redirection: { type: String },
    
    // Date de création de la notification
    date_notification: { type: Date, default: Date.now },
    
    // Type de notification (système, alerte, rappel, etc.)
    type_notification: { type: String, required: true },
    
    // Priorité de la notification (haute, moyenne, basse)
    priorité: { type: String, required: true },
    
    // Date d'expiration de la notification
    date_expiration: { type: Date }
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.model('Notification', NotificationSchema);
