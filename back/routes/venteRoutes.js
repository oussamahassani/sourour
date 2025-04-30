const express = require('express');
const router = express.Router();
const VenteController = require('../controllers/vente.contoller');

// Routes pour les ventes
router.post('/create', VenteController.createVente);
router.get('/', VenteController.getAllVentes);
router.get('/:idV', VenteController.getVenteById);
router.put('/:idV', VenteController.updateVente);
router.delete('/:idV', VenteController.deleteVente);
router.put('/validate/:idV', VenteController.validateVente);

module.exports = router;
