const express = require('express');
const router = express.Router();
const AdminController = require('../controllers/admin.controller');

// Routes pour les administrateurs
router.post('/ajouter', AdminController.ajouterAdmin);     // Ajouter un admin
router.get('/liste', AdminController.listerAdmins);        // Lister les admins
router.get('/:id', AdminController.getAdminById);          // Obtenir un admin par ID
router.put('/:id', AdminController.updateAdmin);           // Mettre à jour un admin
router.delete('/:id', AdminController.supprimerAdmin);     // Supprimer un admin

module.exports = router;
