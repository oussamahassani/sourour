const express = require('express');
const { signup } = require('../controllers/utilisateurs.controller'); // Assurez-vous que le chemin est correct
const router = express.Router();

// Route pour l'inscription
router.post('/signup', signup);

module.exports = router;
