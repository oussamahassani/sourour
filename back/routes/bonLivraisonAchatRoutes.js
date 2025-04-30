// routes/bonLivraisonAchatRoutes.js
const express = require('express');
const router = express.Router();
const bonLivraisonAchatController = require('../controllers/bonLivraisonAchatController');

// Ajouter un bon de livraison d'achat
router.post('/ajouter', bonLivraisonAchatController.ajouterBonLivraisonAchat);

// Lister tous les bons de livraison d'achat
router.get('/', bonLivraisonAchatController.listerBonsLivraisonAchat);

// Récupérer un bon de livraison d'achat par ID
router.get('/:id', bonLivraisonAchatController.getBonLivraisonAchatById);

// Modifier un bon de livraison d'achat
router.put('/:id', bonLivraisonAchatController.modifierBonLivraisonAchat);

// Supprimer un bon de livraison d'achat
router.delete('/:id', bonLivraisonAchatController.supprimerBonLivraisonAchat);

module.exports = router;
