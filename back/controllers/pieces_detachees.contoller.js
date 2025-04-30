const Piece = require('../models/Pieces_detachees'); // Assurez-vous que ce chemin est correct

// Ajouter une nouvelle pièce
exports.ajouterPiece = async (req, res) => {
    try {
        const nouvellePiece = new Piece(req.body);
        await nouvellePiece.save();
        res.status(201).json({ message: "Pièce ajoutée avec succès", piece: nouvellePiece });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de l'ajout de la pièce", error });
    }
};

// Récupérer toutes les pièces
exports.getAllPieces = async (req, res) => {
    try {
        const pieces = await Piece.find();
        res.status(200).json(pieces);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de la récupération des pièces", error });
    }
};

// Récupérer une pièce par son ID
exports.getPieceById = async (req, res) => {
    try {
        const piece = await Piece.findById(req.params.id);
        if (!piece) {
            return res.status(404).json({ message: "Pièce non trouvée" });
        }
        res.status(200).json(piece);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de la récupération de la pièce", error });
    }
};

// Mettre à jour une pièce
exports.updatePiece = async (req, res) => {
    try {
        const piece = await Piece.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!piece) {
            return res.status(404).json({ message: "Pièce non trouvée" });
        }
        res.status(200).json({ message: "Pièce mise à jour", piece });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de la mise à jour de la pièce", error });
    }
};

// Supprimer une pièce
exports.deletePiece = async (req, res) => {
    try {
        const piece = await Piece.findByIdAndDelete(req.params.id);
        if (!piece) {
            return res.status(404).json({ message: "Pièce non trouvée" });
        }
        res.status(200).json({ message: "Pièce supprimée avec succès" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de la suppression de la pièce", error });
    }
};
