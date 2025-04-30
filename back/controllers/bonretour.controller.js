// controllers/bonsRetoursController.js
const BonsRetour = require('../models/BonRetour');

// Ajouter un bon de retour
exports.ajouterBonRetour = async (req, res) => {
  try {
    const { id_vente, id_client, montant_total, date_retour, statut } = req.body;

    const newBonRetour = new BonsRetour({
      id_vente,
      id_client,
      montant_total,
      date_retour,
      statut
    });

    await newBonRetour.save();
    res.status(201).json({ message: "Bon de retour ajouté avec succès", bonRetour: newBonRetour });

  } catch (error) {
    console.error("Erreur lors de l'ajout du bon de retour :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout du bon de retour" });
  }
};

// Lister tous les bons de retour
exports.listeBonsRetours = async (req, res) => {
  try {
    const bonsRetours = await BonsRetour.find()
      .populate('id_vente', 'num_facture')  // Populate 'num_facture' from the related vente (sale)
      .populate('id_client', 'nom');       // Populate 'nom' from the related client

    res.status(200).json({ bonsRetours });

  } catch (error) {
    console.error("Erreur lors de la récupération des bons de retour :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des bons de retour" });
  }
};

// Récupérer un bon de retour par ID
exports.getBonRetourById = async (req, res) => {
  try {
    const { id } = req.params;
    const bonRetour = await BonsRetour.findById(id);

    if (!bonRetour) {
      return res.status(404).json({ error: "Bon de retour non trouvé" });
    }

    res.status(200).json({ bonRetour });

  } catch (error) {
    console.error("Erreur lors de la récupération du bon de retour :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// Modifier un bon de retour
exports.modifierBonRetour = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedBonRetour = await BonsRetour.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedBonRetour) {
      return res.status(404).json({ error: "Bon de retour non trouvé" });
    }

    res.status(200).json({ message: "Bon de retour mis à jour avec succès", bonRetour: updatedBonRetour });

  } catch (error) {
    console.error("Erreur lors de la mise à jour du bon de retour :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour du bon de retour" });
  }
};

// Supprimer un bon de retour
exports.supprimerBonRetour = async (req, res) => {
  try {
    const { id } = req.params;
    const bonRetour = await BonsRetour.findByIdAndDelete(id);

    if (!bonRetour) {
      return res.status(404).json({ error: "Bon de retour non trouvé" });
    }

    res.status(200).json({ message: "Bon de retour supprimé avec succès" });

  } catch (error) {
    console.error("Erreur lors de la suppression du bon de retour :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression du bon de retour" });
  }
};
