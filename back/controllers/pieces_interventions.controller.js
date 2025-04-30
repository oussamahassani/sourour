const Piece = require('../models/Pieces_interventions');

// Créer une nouvelle pièce
exports.createPiece = async (req, res) => {
    try {
        const newPiece = new Piece(req.body);
        const savedPiece = await newPiece.save();
        res.status(201).json(savedPiece);
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la création de la pièce', error });
    }
};

// Obtenir toutes les pièces
exports.getAllPieces = async (req, res) => {
    try {
        const pieces = await Piece.find().populate('id_fournisseur').populate('compatible_avec');
        res.status(200).json(pieces);
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la récupération des pièces', error });
    }
};

// Obtenir une pièce par ID
exports.getPieceById = async (req, res) => {
    try {
        const piece = await Piece.findById(req.params.id).populate('id_fournisseur').populate('compatible_avec');
        if (!piece) {
            return res.status(404).json({ message: 'Pièce non trouvée' });
        }
        res.status(200).json(piece);
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la récupération de la pièce', error });
    }
};

// Mettre à jour une pièce
exports.updatePiece = async (req, res) => {
    try {
        const updatedPiece = await Piece.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedPiece) {
            return res.status(404).json({ message: 'Pièce non trouvée' });
        }
        res.status(200).json(updatedPiece);
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la mise à jour de la pièce', error });
    }
};

// Supprimer une pièce
exports.deletePiece = async (req, res) => {
    try {
        const deletedPiece = await Piece.findByIdAndDelete(req.params.id);
        if (!deletedPiece) {
            return res.status(404).json({ message: 'Pièce non trouvée' });
        }
        res.status(200).json({ message: 'Pièce supprimée avec succès' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la suppression de la pièce', error });
    }
};
