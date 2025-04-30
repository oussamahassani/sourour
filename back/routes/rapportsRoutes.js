const express = require('express');
const router = express.Router();
const rapportsController = require('../controllers/rapports.controller'); // Adjust the path if necessary

// Ensure the correct controller function is used
router.post('/', rapportsController.createRapport); // createRapport is the controller function

module.exports = router;
