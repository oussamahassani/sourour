const express = require('express');
const router = express.Router();
const { ajouterMouvement, listerMouvements, mettreAJourMouvement, supprimerMouvement } = require('../controllers/mouvements_stock.contoller');

// Route POST pour ajouter un mouvement
router.post('/ajouter', ajouterMouvement);

// Route GET pour lister tous les mouvements
router.get('/', listerMouvements);

// Route PUT pour mettre à jour un mouvement
router.put('/:id', mettreAJourMouvement);

// Route DELETE pour supprimer un mouvement
router.delete('/:id', supprimerMouvement);

module.exports = router;
