const express = require('express');
const router = express.Router();
const encaissementController = require('../controllers/encaissementController');

// 📌 Ajouter un encaissement
router.post('/encaissements', encaissementController.ajouterEncaissement);

// 📌 Lister tous les encaissements
router.get('/encaissements', encaissementController.listerEncaissements);

// 📌 Récupérer un encaissement par ID
router.get('/encaissements/:id', encaissementController.getEncaissementById);

// 📌 Modifier un encaissement
router.put('/encaissements/:id', encaissementController.modifierEncaissement);

// 📌 Supprimer un encaissement
router.delete('/encaissements/:id', encaissementController.supprimerEncaissement);

module.exports = router;
