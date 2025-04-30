const express = require('express');
const router = express.Router();
const planningController = require('../controllers/planning_techniciens.contoller');

// Créer un nouveau planning
router.post('/plannings', planningController.createPlanning);

// Récupérer tous les plannings
router.get('/plannings', planningController.getAllPlannings);

// Récupérer un planning par ID
router.get('/plannings/:id', planningController.getPlanningById);

// Mettre à jour un planning
router.put('/plannings/:id', planningController.updatePlanning);

// Supprimer un planning
router.delete('/plannings/:id', planningController.deletePlanning);

module.exports = router;
