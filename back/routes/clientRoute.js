// routes/clientRoutes.js
const express = require('express');
const router = express.Router();
const clientController = require('../controllers/clientController');

// Ajouter un client
router.post('/clients', clientController.ajouterClient);

// Lister tous les clients
router.get('/clients', clientController.listerClients);

// Récupérer un client par ID
router.get('/clients/:id', clientController.getClientById);

// Modifier un client
router.put('/clients/:id', clientController.modifierClient);

// Supprimer un client
router.delete('/clients/:id', clientController.supprimerClient);

module.exports = router;
