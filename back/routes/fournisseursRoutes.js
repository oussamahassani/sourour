// routes/fournisseursRoutes.js
const express = require('express');
const router = express.Router();
const fournisseursController = require('../controllers/fournisseurs.controller'); // Assurez-vous que le chemin est correct

// 📌 Ajouter un fournisseur
router.post('/fournisseurs', fournisseursController.ajouterFournisseur);

// 📌 Lister tous les fournisseurs
router.get('/fournisseurs', fournisseursController.listeFournisseurs);

// 📌 Récupérer un fournisseur par ID
router.get('/fournisseurs/:id', fournisseursController.getFournisseurById);

// 📌 Mettre à jour un fournisseur
router.put('/fournisseurs/:id', fournisseursController.mettreAJourFournisseur);

// 📌 Supprimer un fournisseur
router.delete('/fournisseurs/:id', fournisseursController.supprimerFournisseur);

module.exports = router;
