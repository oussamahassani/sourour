const express = require('express');
const router = express.Router();
const { ajouterInterventionRepport,
    ajouterIntervention, listeInterventions,
     mettreAJourIntervention, supprimerIntervention,
     mettreAJourInterventionRepport,
     listeInterventionRepport,
     getoneInterventionRepport
     } = require('../controllers/interventions.contoller');

// Route POST pour ajouter une intervention
router.post('/ajouter', ajouterIntervention);
router.post('/ajouterRepport', ajouterInterventionRepport);
router.get('/all/report', listeInterventionRepport);
router.get('/all/report/:id', getoneInterventionRepport);

router.put('/all/report/:id', mettreAJourInterventionRepport);

// Route GET pour lister toutes les interventions
router.get('/', listeInterventions);

// Route PUT pour mettre à jour une intervention
router.put('/:id', mettreAJourIntervention);

// Route DELETE pour supprimer une intervention
router.delete('/:id', supprimerIntervention);

module.exports = router;
