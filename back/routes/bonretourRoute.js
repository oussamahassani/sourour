// routes/bonsRetours.js
const express = require('express');
const router = express.Router();
const bonsRetoursController = require('../controllers/bonretour.controller');

// Route to add a new bon de retour
router.post('/bons-retours', bonsRetoursController.ajouterBonRetour);

// Route to list all bons de retour
router.get('/bons-retours', bonsRetoursController.listeBonsRetours);

// Route to get a specific bon de retour by ID
router.get('/bons-retours/:id', bonsRetoursController.getBonRetourById);

// Route to update a bon de retour by ID
router.put('/bons-retours/:id', bonsRetoursController.modifierBonRetour);

// Route to delete a bon de retour by ID
router.delete('/bons-retours/:id', bonsRetoursController.supprimerBonRetour);

module.exports = router;
