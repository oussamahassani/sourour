const Paiement = require('../models/Paiements'); // Assurez-vous que ce chemin est correct

// Ajouter un paiement
exports.ajouterPaiement = async (req, res) => {
    try {
        if(!req.body.fournisseur
){
            delete req.body.fournisseur
console.log("ok")
        }
        console.log(req.body)
        const paiement = new Paiement(req.body);
        await paiement.save();
        res.status(201).json({ message: "Paiement ajouté avec succès", paiement });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de l'ajout du paiement", error });
    }
};

// Récupérer tous les paiements
exports.getAllPaiements = async (req, res) => {
    try {
        const paiements = await Paiement.find();
        res.status(200).json(paiements);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de la récupération des paiements", error });
    }
};

// Récupérer un paiement par ID
exports.getPaiementById = async (req, res) => {
    try {
        const paiement = await Paiement.findById(req.params.id);
        if (!paiement) {
            return res.status(404).json({ message: "Paiement non trouvé" });
        }
        res.status(200).json(paiement);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de la récupération du paiement", error });
    }
};

// Mettre à jour un paiement
exports.updatePaiement = async (req, res) => {
    try {
        const paiement = await Paiement.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!paiement) {
            return res.status(404).json({ message: "Paiement non trouvé" });
        }
        res.status(200).json({ message: "Paiement mis à jour", paiement });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de la mise à jour du paiement", error });
    }
};

// Supprimer un paiement
exports.deletePaiement = async (req, res) => {
    try {
        const paiement = await Paiement.findByIdAndDelete(req.params.id);
        if (!paiement) {
            return res.status(404).json({ message: "Paiement non trouvé" });
        }
        res.status(200).json({ message: "Paiement supprimé avec succès" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de la suppression du paiement", error });
    }
};
