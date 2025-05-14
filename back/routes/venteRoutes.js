const express = require('express');
const router = express.Router();
const devisController = require('../controllers/vente.contoller');


// Complete method devis routes
router.post('/', devisController.createDevisComplete);
router.get('/', devisController.getAllDevis);
router.get('/:id', devisController.getDevisById);
router.patch('/:id/status', devisController.updateDevisStatus);
router.delete('/:id', devisController.deleteDevis);
router.get('/:id/pdf', devisController.generateDevisPDF);


// Quick method devis routes
//router.post('/rapide', uploadMiddleware.single('imageDevis'), devisController.createDevisRapide);


module.exports = router;
