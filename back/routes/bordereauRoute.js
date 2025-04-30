// routes/bordereauxRoutes.js
const express = require('express');
const router = express.Router();
const bordereauxController = require('../controllers/bordereau.Controller');

// Ajouter un bordereau
router.post('/bordereaux', bordereauxController.ajouterBordereau);

// Lister tous les bordereaux
router.get('/bordereaux', bordereauxController.listerBordereaux);

// Récupérer un bordereau par ID
router.get('/bordereaux/:id', bordereauxController.getBordereauById);

// Modifier un bordereau
router.put('/bordereaux/:id', bordereauxController.modifierBordereau);

// Supprimer un bordereau
router.delete('/bordereaux/:id', bordereauxController.supprimerBordereau);

module.exports = router;
