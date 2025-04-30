const express = require('express');
const router = express.Router();
const ficheBaieController = require('../controllers/ficheBaieController');

// 📌 Ajouter une fiche baie
router.post('/fiche-baie', ficheBaieController.ajouterFicheBaie);

// 📌 Lister toutes les fiches baies
router.get('/fiche-baie', ficheBaieController.listerFichesBaies);

// 📌 Récupérer une fiche baie par ID
router.get('/fiche-baie/:id', ficheBaieController.getFicheBaieById);

// 📌 Modifier une fiche baie
router.put('/fiche-baie/:id', ficheBaieController.modifierFicheBaie);

// 📌 Supprimer une fiche baie
router.delete('/fiche-baie/:id', ficheBaieController.supprimerFicheBaie);

module.exports = router;
