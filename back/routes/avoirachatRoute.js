const express = require('express');
const router = express.Router();
const { body, param } = require('express-validator');
const AvoirAchatController = require('../controllers/avoirachat.controller');
const mongoose = require('mongoose');

// Middleware pour vérifier si l'ID est un ObjectId valide
const checkObjectId = param('id').custom((value) => {
  if (!mongoose.Types.ObjectId.isValid(value)) {
    throw new Error('ID invalide');
  }
  return true;
});

// Routes CRUD pour les avoirs sur achat

// Ajouter un avoir sur achat
router.post(
  '/ajouter',
  [
    body('id_achat').notEmpty().withMessage("L'ID de l'achat est requis"),
    body('id_fournisseur').notEmpty().withMessage("L'ID du fournisseur est requis"),
    body('montant_avoir').isFloat({ min: 0 }).withMessage("Le montant doit être un nombre positif"),
  ],
  AvoirAchatController.ajouterAvoirAchat
);

// Lister tous les avoirs sur achat
router.get('/liste', AvoirAchatController.listeAvoirsAchat);

// Récupérer un avoir sur achat par ID
router.get('/:id', checkObjectId, AvoirAchatController.getAvoirAchatById);

// Modifier un avoir sur achat
router.put('/modifier/:id', checkObjectId, AvoirAchatController.modifierAvoirAchat);

// Supprimer un avoir sur achat
router.delete('/supprimer/:id', checkObjectId, AvoirAchatController.supprimerAvoirAchat);

module.exports = router;
