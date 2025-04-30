const express = require('express');
const router = express.Router();
const bonSortieController = require('../controllers/bonSortie.controller');

// Ajouter un bon de sortie
router.post('/bon-sortie', bonSortieController.ajouterBonSortie);

// Lister tous les bons de sortie
router.get('/bon-sortie', bonSortieController.listerBonsSortie);

// Récupérer un bon de sortie par ID
router.get('/bon-sortie/:id', bonSortieController.getBonSortieById);

// Modifier un bon de sortie
router.put('/bon-sortie/:id', bonSortieController.modifierBonSortie);

// Supprimer un bon de sortie
router.delete('/bon-sortie/:id', bonSortieController.supprimerBonSortie);

module.exports = router;
