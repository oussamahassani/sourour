const express = require('express');
const router = express.Router();
const financeController = require('../controllers/financeController');

// 📌 Ajouter un mouvement financier
router.post('/finance', financeController.ajouterMouvement);

// 📌 Lister tous les mouvements financiers
router.get('/finance', financeController.listerMouvements);

// 📌 Récupérer un mouvement financier par ID
router.get('/finance/:id', financeController.getMouvementById);

// 📌 Modifier un mouvement financier
router.put('/finance/:id', financeController.modifierMouvement);

// 📌 Supprimer un mouvement financier
router.delete('/finance/:id', financeController.supprimerMouvement);

module.exports = router;
