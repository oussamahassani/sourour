const express = require('express');
const router = express.Router();
const permissionController = require('../controllers/permissions.contoller');

// Ajouter une permission
router.post('/ajouter', permissionController.ajouterPermission);

// Récupérer toutes les permissions
router.get('/', permissionController.getAllPermissions);

// Récupérer une permission par ID
router.get('/:id', permissionController.getPermissionById);

// Mettre à jour une permission
router.put('/:id', permissionController.updatePermission);

// Supprimer une permission
router.delete('/:id', permissionController.deletePermission);

module.exports = router;
