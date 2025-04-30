const express = require('express');
const router = express.Router();
const paiementController = require('../controllers/paiements.controller');

// Ajouter un paiement
router.post('/ajouter', paiementController.ajouterPaiement);

// Récupérer tous les paiements
router.get('/', paiementController.getAllPaiements);

// Récupérer un paiement par ID
router.get('/:id', paiementController.getPaiementById);

// Mettre à jour un paiement
router.put('/:id', paiementController.updatePaiement);

// Supprimer un paiement
router.delete('/:id', paiementController.deletePaiement);

module.exports = router;
