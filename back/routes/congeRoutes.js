const express = require('express');
const router = express.Router();
const congeController = require('../controllers/congeController');

// 📌 Ajouter une demande de congé
router.post('/conges', congeController.ajouterConge);

// 📌 Lister toutes les demandes de congé
router.get('/conges', congeController.listerConges);

// 📌 Récupérer une demande de congé par ID
router.get('/conges/:id', congeController.getCongeById);

// 📌 Modifier une demande de congé
router.put('/conges/:id', congeController.modifierConge);

// 📌 Supprimer une demande de congé
router.delete('/conges/:id', congeController.supprimerConge);

// 📌 Approuver ou refuser une demande de congé
router.patch('/conges/:id/statut', congeController.changerStatutConge);

module.exports = router;
