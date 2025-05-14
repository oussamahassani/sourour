const express = require('express');
const router = express.Router();
const financeController = require('../controllers/financeController');

// Routes pour les transactions
router.post('/', financeController.createRecord);
router.get('/records', financeController.getAllRecords);
router.get('/records/:id', financeController.getRecordById);
router.put('/records/:id', financeController.updateRecord);
router.delete('/records/:id', financeController.deleteRecord);

// Routes pour les statistiques
router.get('/stats', financeController.getFinancialStats);

module.exports = router;
