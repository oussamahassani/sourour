const express = require('express');
const router = express.Router();
const pieceController = require('../controllers/pieces_detachees.contoller');

// Ajouter une pièce
router.post('/ajouter', pieceController.ajouterPiece);

// Récupérer toutes les pièces
router.get('/', pieceController.getAllPieces);

// Récupérer une pièce par ID
router.get('/:id', pieceController.getPieceById);

// Mettre à jour une pièce
router.put('/:id', pieceController.updatePiece);

// Supprimer une pièce
router.delete('/:id', pieceController.deletePiece);

module.exports = router;
