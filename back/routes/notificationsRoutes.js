const express = require('express');
const router = express.Router();
const { ajouterNotification, getAllNotifications, updateNotificationStatus, deleteNotification } = require('../controllers/notifications.contoller');

// Ajouter une notification
router.post('/ajouter', ajouterNotification);

// Récupérer toutes les notifications
router.get('/', getAllNotifications);

// Mettre à jour le statut d'une notification
router.put('/:id', updateNotificationStatus);

// Supprimer une notification
router.delete('/:id', deleteNotification);

module.exports = router;
