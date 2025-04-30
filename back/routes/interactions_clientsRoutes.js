const express = require('express');
const router = express.Router();
const interactionsClientsController = require('../controllers/interactions_clients.contoller'); // Vérifiez bien le chemin

// Ajouter une interaction client
router.post('/interactions', interactionsClientsController.ajouterInteraction);

// Lister toutes les interactions
router.get('/interactions', interactionsClientsController.listerInteractions);

// Récupérer une interaction par ID
router.get('/interactions/:id', interactionsClientsController.getInteractionById);

// Mettre à jour une interaction
router.put('/interactions/:id', interactionsClientsController.mettreAJourInteraction);

// Supprimer une interaction
router.delete('/interactions/:id', interactionsClientsController.supprimerInteraction);

module.exports = router;
