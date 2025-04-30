// controllers/bonLivraisonVenteController.js
const BonLivraisonVente = require('../models/bonLivraisonVente');

// Ajouter un bon de livraison pour une vente
exports.ajouterBonLivraisonVente = async (req, res) => {
  try {
    const { id_vente, id_client, date_livraison, statut } = req.body;

    const newBonLivraisonVente = new BonLivraisonVente({
      id_vente,
      id_client,
      date_livraison,
      statut
    });

    await newBonLivraisonVente.save();
    res.status(201).json({ message: "Bon de livraison de vente ajouté avec succès", bonLivraisonVente: newBonLivraisonVente });

  } catch (error) {
    console.error("Erreur lors de l'ajout du bon de livraison vente :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout du bon de livraison vente" });
  }
};

// Lister tous les bons de livraison pour les ventes
exports.listerBonsLivraisonVente = async (req, res) => {
  try {
    const bonsLivraisonVente = await BonLivraisonVente.find()
      .populate('id_vente', 'id')  // Replace with actual field you want from 'Vente' model
      .populate('id_client', 'nom');  // Replace with actual field you want from 'Client' model

    res.status(200).json({ bonsLivraisonVente });

  } catch (error) {
    console.error("Erreur lors de la récupération des bons de livraison vente :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des bons de livraison vente" });
  }
};

// Récupérer un bon de livraison de vente par ID
exports.getBonLivraisonVenteById = async (req, res) => {
  try {
    const { id } = req.params;
    const bonLivraisonVente = await BonLivraisonVente.findById(id);

    if (!bonLivraisonVente) {
      return res.status(404).json({ error: "Bon de livraison vente non trouvé" });
    }

    res.status(200).json({ bonLivraisonVente });

  } catch (error) {
    console.error("Erreur lors de la récupération du bon de livraison vente :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// Modifier un bon de livraison pour une vente
exports.modifierBonLivraisonVente = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedBonLivraisonVente = await BonLivraisonVente.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedBonLivraisonVente) {
      return res.status(404).json({ error: "Bon de livraison vente non trouvé" });
    }

    res.status(200).json({ message: "Bon de livraison vente mis à jour avec succès", bonLivraisonVente: updatedBonLivraisonVente });

  } catch (error) {
    console.error("Erreur lors de la mise à jour du bon de livraison vente :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour du bon de livraison vente" });
  }
};

// Supprimer un bon de livraison de vente
exports.supprimerBonLivraisonVente = async (req, res) => {
  try {
    const { id } = req.params;
    const bonLivraisonVente = await BonLivraisonVente.findByIdAndDelete(id);

    if (!bonLivraisonVente) {
      return res.status(404).json({ error: "Bon de livraison vente non trouvé" });
    }

    res.status(200).json({ message: "Bon de livraison vente supprimé avec succès" });

  } catch (error) {
    console.error("Erreur lors de la suppression du bon de livraison vente :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression du bon de livraison vente" });
  }
};
