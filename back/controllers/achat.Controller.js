const Achat = require('../models/Achat');

// Ajouter un achat
exports.ajouterAchat = async (req, res) => {
  try {
    const newAchat = new Achat(req.body);
    await newAchat.save();
    res.status(201).json({ message: 'Achat ajouté avec succès', achat: newAchat });
  } catch (error) {
    console.error("Erreur lors de l'ajout de l'achat :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout de l'achat" });
  }
};

// Lister tous les achats
exports.listeAchats = async (req, res) => {
  try {
    const achats = await Achat.find().populate('id_article id_fournisseur id_utilisateur id_paiement id_document');
    res.status(200).json({ achats });
  } catch (error) {
    console.error("Erreur lors de la récupération des achats :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des achats" });
  }
};

// Récupérer un achat par ID
exports.getAchatById = async (req, res) => {
  try {
    const { id } = req.params;
    const achat = await Achat.findById(id).populate('id_article id_fournisseur id_utilisateur id_paiement id_document');

    if (!achat) {
      return res.status(404).json({ error: "Achat non trouvé" });
    }

    res.status(200).json({ achat });
  } catch (error) {
    console.error("Erreur lors de la récupération de l'achat :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// Modifier un achat
exports.modifierAchat = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedAchat = await Achat.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedAchat) {
      return res.status(404).json({ error: "Achat non trouvé" });
    }

    res.status(200).json({ message: "Achat mis à jour avec succès", achat: updatedAchat });
  } catch (error) {
    console.error("Erreur lors de la mise à jour de l'achat :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour de l'achat" });
  }
};

// Supprimer un achat
exports.supprimerAchat = async (req, res) => {
  try {
    const { id } = req.params;
    const achat = await Achat.findByIdAndDelete(id);

    if (!achat) {
      return res.status(404).json({ error: "Achat non trouvé" });
    }

    res.status(200).json({ message: "Achat supprimé avec succès" });
  } catch (error) {
    console.error("Erreur lors de la suppression de l'achat :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression de l'achat" });
  }
};
