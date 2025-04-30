const express = require('express');
const router = express.Router();
const compteController = require('../controllers/compte.Controller');

// 📌 Ajouter un compte
router.post('/compte', compteController.ajouterCompte);

// 📌 Lister tous les comptes
router.get('/compte', compteController.listerComptes);

// 📌 Récupérer un compte par ID
router.get('/compte/:id', compteController.getCompteById);

// 📌 Modifier un compte
router.put('/compte/:id', compteController.modifierCompte);

// 📌 Supprimer un compte
router.delete('/compte/:id', compteController.supprimerCompte);

module.exports = router;
