const express = require('express');
const router = express.Router();
const bonTransfertController = require('../controllers/bonTransfert.Controller'); // Assurez-vous que le chemin est correct

// Ajouter un bon de transfert
router.post('/bon-transfert', bonTransfertController.ajouterBonTransfert);

// Lister tous les bons de transfert
router.get('/bon-transfert', bonTransfertController.listerBonsTransfert); // Assurez-vous que cette méthode existe dans le contrôleur

// Récupérer un bon de transfert par ID
router.get('/bon-transfert/:id', bonTransfertController.getBonTransfertById);

// Modifier un bon de transfert
router.put('/bon-transfert/:id', bonTransfertController.modifierBonTransfert);

// Supprimer un bon de transfert
router.delete('/bon-transfert/:id', bonTransfertController.supprimerBonTransfert);

module.exports = router;
