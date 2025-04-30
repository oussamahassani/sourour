const express = require('express');
const router = express.Router();
const { ajouterIntervention, listeInterventions, mettreAJourIntervention, supprimerIntervention } = require('../controllers/interventions.contoller');

// Route POST pour ajouter une intervention
router.post('/ajouter', ajouterIntervention);

// Route GET pour lister toutes les interventions
router.get('/', listeInterventions);

// Route PUT pour mettre à jour une intervention
router.put('/:id', mettreAJourIntervention);

// Route DELETE pour supprimer une intervention
router.delete('/:id', supprimerIntervention);

module.exports = router;
