// routes/garantiesRoutes.js
const express = require('express');
const router = express.Router();
const garantiesController = require('../controllers/garanties_contrats.contoller');

// Ajouter une garantie
router.post('/garanties', garantiesController.ajouterGarantie);

// Lister toutes les garanties
router.get('/garanties', garantiesController.listerGaranties);

// Récupérer une garantie par ID
router.get('/garanties/:id', garantiesController.getGarantieById);

// Mettre à jour une garantie
router.put('/garanties/:id', garantiesController.mettreAJourGarantie);

// Supprimer une garantie
router.delete('/garanties/:id', garantiesController.supprimerGarantie);

module.exports = router;
