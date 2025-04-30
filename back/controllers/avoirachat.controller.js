const AvoirAchat = require('../models/AvoirAchat');
const Achat = require('../models/Achat');  // Assurez-vous d'avoir ce modèle
const Fournisseur = require('../models/Fournisseur');

// Ajouter un avoir sur achat
exports.ajouterAvoirAchat = async (req, res) => {
  try {
    const { id_achat, id_fournisseur, montant_avoir, date_avoir, statut } = req.body;

    // Vérifier l'existence de l'achat et du fournisseur
    const achatExiste = await Achat.findById(id_achat);
    const fournisseurExiste = await Fournisseur.findById(id_fournisseur);

    if (!achatExiste) return res.status(404).json({ error: "Achat non trouvé" });
    if (!fournisseurExiste) return res.status(404).json({ error: "Fournisseur non trouvé" });

    const newAvoirAchat = new AvoirAchat({
      id_achat,
      id_fournisseur,
      montant_avoir,
      date_avoir,
      statut
    });

    await newAvoirAchat.save();
    res.status(201).json({ message: "Avoir ajouté avec succès", avoirAchat: newAvoirAchat });
  } catch (error) {
    console.error("Erreur lors de l'ajout de l'avoir sur achat :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout de l'avoir sur achat" });
  }
};

// Lister tous les avoirs sur achat
exports.listeAvoirsAchat = async (req, res) => {
  try {
    const avoirsAchat = await AvoirAchat.find()
      .populate('id_achat', 'num_achat montant_total') // Récupérer les infos de l'achat
      .populate('id_fournisseur', 'nom') // Récupérer les infos du fournisseur

    res.status(200).json({ avoirsAchat });
  } catch (error) {
    console.error("Erreur lors de la récupération des avoirs sur achat :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des avoirs sur achat" });
  }
};

// Récupérer un avoir sur achat par ID
exports.getAvoirAchatById = async (req, res) => {
  try {
    const { id } = req.params;
    const avoirAchat = await AvoirAchat.findById(id)
      .populate('id_achat', 'num_achat montant_total')
      .populate('id_fournisseur', 'nom');

    if (!avoirAchat) {
      return res.status(404).json({ error: "Avoir non trouvé" });
    }

    res.status(200).json({ avoirAchat });
  } catch (error) {
    console.error("Erreur lors de la récupération de l'avoir sur achat :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// Modifier un avoir sur achat
exports.modifierAvoirAchat = async (req, res) => {
  try {
    const { id } = req.params;

    const updatedAvoirAchat = await AvoirAchat.findByIdAndUpdate(id, req.body, { new: true, runValidators: true })
      .populate('id_achat', 'num_achat')
      .populate('id_fournisseur', 'nom');

    if (!updatedAvoirAchat) {
      return res.status(404).json({ error: "Avoir non trouvé" });
    }

    res.status(200).json({ message: "Avoir mis à jour avec succès", avoirAchat: updatedAvoirAchat });
  } catch (error) {
    console.error("Erreur lors de la mise à jour de l'avoir sur achat :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour de l'avoir sur achat" });
  }
};

// Supprimer un avoir sur achat
exports.supprimerAvoirAchat = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedAvoirAchat = await AvoirAchat.findByIdAndDelete(id);

    if (!deletedAvoirAchat) {
      return res.status(404).json({ error: "Avoir non trouvé" });
    }

    res.status(200).json({ message: "Avoir supprimé avec succès" });
  } catch (error) {
    console.error("Erreur lors de la suppression de l'avoir sur achat :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression de l'avoir sur achat" });
  }
};
