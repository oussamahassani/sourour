// controllers/bonLivraisonAchatController.js
const BonLivraisonAchat = require('../models/BonLivraisonAchat');

// Ajouter un bon de livraison pour un achat
exports.ajouterBonLivraisonAchat = async (req, res) => {
  try {
    const { id_achat, id_fournisseur, date_livraison, statut } = req.body;

    const newBonLivraisonAchat = new BonLivraisonAchat({
      id_achat,
      id_fournisseur,
      date_livraison,
      statut
    });

    await newBonLivraisonAchat.save();
    res.status(201).json({ message: "Bon de livraison d'achat ajouté avec succès", bonLivraisonAchat: newBonLivraisonAchat });

  } catch (error) {
    console.error("Erreur lors de l'ajout du bon de livraison achat :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout du bon de livraison achat" });
  }
};

// Lister tous les bons de livraison pour les achats
exports.listerBonsLivraisonAchat = async (req, res) => {
  try {
    const bonsLivraisonAchat = await BonLivraisonAchat.find()
      .populate('id_achat', 'id')  // Replace with actual field you want from 'Achat' model
      .populate('id_fournisseur', 'nom');  // Replace with actual field you want from 'Fournisseur' model

    res.status(200).json({ bonsLivraisonAchat });

  } catch (error) {
    console.error("Erreur lors de la récupération des bons de livraison achat :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des bons de livraison achat" });
  }
};

// Récupérer un bon de livraison d'achat par ID
exports.getBonLivraisonAchatById = async (req, res) => {
  try {
    const { id } = req.params;
    const bonLivraisonAchat = await BonLivraisonAchat.findById(id);

    if (!bonLivraisonAchat) {
      return res.status(404).json({ error: "Bon de livraison achat non trouvé" });
    }

    res.status(200).json({ bonLivraisonAchat });

  } catch (error) {
    console.error("Erreur lors de la récupération du bon de livraison achat :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// Modifier un bon de livraison pour un achat
exports.modifierBonLivraisonAchat = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedBonLivraisonAchat = await BonLivraisonAchat.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedBonLivraisonAchat) {
      return res.status(404).json({ error: "Bon de livraison achat non trouvé" });
    }

    res.status(200).json({ message: "Bon de livraison achat mis à jour avec succès", bonLivraisonAchat: updatedBonLivraisonAchat });

  } catch (error) {
    console.error("Erreur lors de la mise à jour du bon de livraison achat :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour du bon de livraison achat" });
  }
};

// Supprimer un bon de livraison d'achat
exports.supprimerBonLivraisonAchat = async (req, res) => {
  try {
    const { id } = req.params;
    const bonLivraisonAchat = await BonLivraisonAchat.findByIdAndDelete(id);

    if (!bonLivraisonAchat) {
      return res.status(404).json({ error: "Bon de livraison achat non trouvé" });
    }

    res.status(200).json({ message: "Bon de livraison achat supprimé avec succès" });

  } catch (error) {
    console.error("Erreur lors de la suppression du bon de livraison achat :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression du bon de livraison achat" });
  }
};
