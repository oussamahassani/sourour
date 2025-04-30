// controllers/compteController.js
const Compte = require('../models/Comptes');

// Ajouter un compte
exports.ajouterCompte = async (req, res) => {
  try {
    const { nom_compte, type_compte, solde, numero_compte, banque, devise } = req.body;

    const newCompte = new Compte({
      nom_compte,
      type_compte,
      solde,
      numero_compte,
      banque,
      devise
    });

    await newCompte.save();
    res.status(201).json({ message: 'Compte ajouté avec succès', compte: newCompte });
  } catch (error) {
    console.error("Erreur lors de l'ajout du compte :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout du compte" });
  }
};

// Lister tous les comptes
exports.listerComptes = async (req, res) => {
  try {
    const comptes = await Compte.find();
    res.status(200).json({ comptes });
  } catch (error) {
    console.error("Erreur lors de la récupération des comptes :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des comptes" });
  }
};

// Récupérer un compte par ID
exports.getCompteById = async (req, res) => {
  try {
    const { id } = req.params;
    const compte = await Compte.findById(id);

    if (!compte) {
      return res.status(404).json({ error: "Compte non trouvé" });
    }

    res.status(200).json({ compte });
  } catch (error) {
    console.error("Erreur lors de la récupération du compte :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération du compte" });
  }
};

// Modifier un compte
exports.modifierCompte = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedCompte = await Compte.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedCompte) {
      return res.status(404).json({ error: "Compte non trouvé" });
    }

    res.status(200).json({ message: "Compte mis à jour avec succès", compte: updatedCompte });
  } catch (error) {
    console.error("Erreur lors de la mise à jour du compte :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour du compte" });
  }
};

// Supprimer un compte
exports.supprimerCompte = async (req, res) => {
  try {
    const { id } = req.params;
    const compte = await Compte.findByIdAndDelete(id);

    if (!compte) {
      return res.status(404).json({ error: "Compte non trouvé" });
    }

    res.status(200).json({ message: "Compte supprimé avec succès" });
  } catch (error) {
    console.error("Erreur lors de la suppression du compte :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression du compte" });
  }
};
