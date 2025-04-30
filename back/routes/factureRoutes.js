const express = require('express');
const router = express.Router();
const factureController = require('../controllers/factureController');

// 📌 Ajouter une facture
router.post('/factures', factureController.ajouterFacture);

// 📌 Lister toutes les factures
router.get('/factures', factureController.listerFactures);

// 📌 Récupérer une facture par ID
router.get('/factures/:id', factureController.getFactureById);

// 📌 Modifier une facture
router.put('/factures/:id', factureController.modifierFacture);

// 📌 Supprimer une facture
router.delete('/factures/:id', factureController.supprimerFacture);

module.exports = router;
