const express = require('express');
const router = express.Router();
const { body, param } = require('express-validator');
const AvoirVenteController = require('../controllers/avoirvente.controller');
const mongoose = require('mongoose');

// Middleware pour vérifier si l'ID est un ObjectId valide
const checkObjectId = param('id').custom((value) => {
  if (!mongoose.Types.ObjectId.isValid(value)) {
    throw new Error('ID invalide');
  }
  return true;
});

// Routes CRUD pour les avoirs sur vente

// Ajouter un avoir sur vente
router.post(
  '/ajouter',
  [
    body('id_vente').notEmpty().withMessage("L'ID de la vente est requis"),
    body('id_client').notEmpty().withMessage("L'ID du client est requis"),
    body('montant_avoir').isFloat({ min: 0 }).withMessage("Le montant doit être un nombre positif"),
  ],
  AvoirVenteController.ajouterAvoirVente
);

// Lister tous les avoirs sur vente
router.get('/liste', AvoirVenteController.listeAvoirsVente);

// Récupérer un avoir sur vente par ID
router.get('/:id', checkObjectId, AvoirVenteController.getAvoirVenteById);

// Modifier un avoir sur vente
router.put('/modifier/:id', checkObjectId, AvoirVenteController.modifierAvoirVente);

// Supprimer un avoir sur vente
router.delete('/supprimer/:id', checkObjectId, AvoirVenteController.supprimerAvoirVente);

module.exports = router;
