const express = require('express');
const router = express.Router();
const AvanceController = require('../controllers/avance.Controller');

// Routes CRUD pour les avances
router.post('/ajouter', AvanceController.ajouterAvance);       // Ajouter une avance
router.get('/liste', AvanceController.listeAvances);          // Lister toutes les avances
router.get('/:id', AvanceController.getAvanceById);           // Récupérer une avance par ID
router.put('/modifier/:id', AvanceController.modifierAvance); // Modifier une avance
router.delete('/supprimer/:id', AvanceController.supprimerAvance); // Supprimer une avance

module.exports = router;
