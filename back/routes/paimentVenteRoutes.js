const express = require('express');
const router = express.Router();
const paiementController = require('../controllers/paimentVenteController'); // Assurez-vous que le nom du fichier est correct

// Créer un nouveau paiement
router.post('/', paiementController.createPaiement);

// Récupérer tous les paiements
router.get('/', paiementController.getAllPaiements);

// Récupérer les paiements d'un client spécifique
router.get('/client/:clientId', paiementController.getPaiementsByClient);

// Récupérer un paiement par ID
router.get('/:id', paiementController.getPaiementById);

// Mettre à jour un paiement
router.put('/:id', paiementController.updatePaiement);

// Supprimer un paiement
router.delete('/:id', paiementController.deletePaiement);

module.exports = router;
