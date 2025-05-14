const express = require('express');
const router = express.Router();
const bonSortieController = require('../controllers/bonSortieController');

// Apply auth middleware to all routes

// Bon de Sortie routes
router.post('/', bonSortieController.createBonSortie);
router.get('/', bonSortieController.getAllBonSortie);
router.get('/:id', bonSortieController.getBonSortieById);
router.put('/:id', bonSortieController.updateBonSortie);
router.patch('/:id/validate', bonSortieController.validateBonSortie);
router.patch('/:id/cancel', bonSortieController.cancelBonSortie);
router.get('/:id/pdf', bonSortieController.generatePdf);

module.exports = router;
