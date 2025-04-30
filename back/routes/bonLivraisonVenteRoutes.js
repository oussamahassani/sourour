// routes/bonLivraisonVenteRoutes.js
const express = require('express');
const router = express.Router();
const bonLivraisonVenteController = require('../controllers/bonLivraisonVenteController');

// Ajouter un bon de livraison de vente
router.post('/ajouter', bonLivraisonVenteController.ajouterBonLivraisonVente);

// Lister tous les bons de livraison de vente
router.get('/', bonLivraisonVenteController.listerBonsLivraisonVente);

// Récupérer un bon de livraison de vente par ID
router.get('/:id', bonLivraisonVenteController.getBonLivraisonVenteById);

// Modifier un bon de livraison de vente
router.put('/:id', bonLivraisonVenteController.modifierBonLivraisonVente);

// Supprimer un bon de livraison de vente
router.delete('/:id', bonLivraisonVenteController.supprimerBonLivraisonVente);

module.exports = router;
