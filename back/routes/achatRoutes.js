const express = require('express');
const router = express.Router();
const AchatController = require('../controllers/achat.Controller');

// Route pour ajouter un achat
router.post('/ajouter', AchatController.ajouterAchat);

// Route pour lister tous les achats
router.get('/liste', AchatController.listeAchats);

// Route pour récupérer un achat par ID
router.get('/:id', AchatController.getAchatById);

// Route pour modifier un achat
router.put('/modifier/:id', AchatController.modifierAchat);

// Route pour supprimer un achat
router.delete('/supprimer/:id', AchatController.supprimerAchat);

module.exports = router;

