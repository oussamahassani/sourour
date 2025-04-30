const express = require('express');
const router = express.Router();
const TableauController = require('../controllers/tableaux_bord.contoller');  // Correct path to controller

// Define the route for creating a tableau
router.post('/tableaux', TableauController.createTableau);

// You can define other routes for listing, updating, or deleting tableaux as needed
// router.get('/tableaux', TableauController.getTableaux);
// router.put('/tableaux/:id', TableauController.updateTableau);
// router.delete('/tableaux/:id', TableauController.deleteTableau);

module.exports = router;
