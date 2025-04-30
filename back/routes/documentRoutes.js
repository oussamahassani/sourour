const express = require('express');
const router = express.Router();
const documentController = require('../controllers/document.Controller');

// 📌 Ajouter un document
router.post('/documents', documentController.ajouterDocument);

// 📌 Lister tous les documents
router.get('/documents', documentController.listerDocuments);

// 📌 Récupérer un document par ID
router.get('/documents/:id', documentController.getDocumentById);

// 📌 Modifier un document
router.put('/documents/:id', documentController.modifierDocument);

// 📌 Supprimer un document
router.delete('/documents/:id', documentController.supprimerDocument);

module.exports = router;
