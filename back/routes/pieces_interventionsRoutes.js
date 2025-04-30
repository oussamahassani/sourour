const express = require('express');
const router = express.Router();
const pieceController = require('../controllers/pieces_interventions.controller');

// Route pour créer une pièce
router.post('/', pieceController.createPiece);

// Route pour récupérer toutes les pièces
router.get('/', pieceController.getAllPieces);

// Route pour récupérer une pièce par ID
router.get('/:id', pieceController.getPieceById);

// Route pour mettre à jour une pièce
router.put('/:id', pieceController.updatePiece);

// Route pour supprimer une pièce
router.delete('/:id', pieceController.deletePiece);

module.exports = router;
