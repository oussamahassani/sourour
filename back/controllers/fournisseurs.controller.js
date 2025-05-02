// controllers/fournisseursController.js
const Fournisseur = require('../models/Fournisseur'); // Assurez-vous que le chemin vers le modèle est correct

// Ajouter un fournisseur
exports.ajouterFournisseur = async (req, res) => {
  try {
    const { nomF, prenomF, entreprise, adresse, telephone, email, matricule, evaluation, notes, conditions_paiement, delai_livraison_moyen } = req.body;

    // Créer un nouveau fournisseur
    const fournisseur = new Fournisseur({
      nomF,
      prenomF,
      entreprise,
      adresse,
      telephone,
      email,
      matricule,
      evaluation,
      notes,
      conditions_paiement,
      delai_livraison_moyen
    });

    // Sauvegarder le fournisseur dans la base de données
    await fournisseur.save();
    res.status(201).json({ message: "Fournisseur ajouté avec succès", fournisseur });
  } catch (error) {
    console.error("Erreur lors de l'ajout du fournisseur", error);
    res.status(500).json({ error: "Erreur lors de l'ajout du fournisseur" });
  }
};

// Lister tous les fournisseurs
exports.listeFournisseurs = async (req, res) => {
  try {
    // Récupérer tous les fournisseurs
    const fournisseurs = await Fournisseur.find();
    res.status(200).json( fournisseurs );
  } catch (error) {
    console.error("Erreur lors de la récupération des fournisseurs", error);
    res.status(500).json({ error: "Erreur lors de la récupération des fournisseurs" });
  }
};

// Récupérer un fournisseur par ID
exports.getFournisseurById = async (req, res) => {
  try {
    const { id } = req.params;
    const fournisseur = await Fournisseur.findById(id);

    if (!fournisseur) {
      return res.status(404).json({ error: "Fournisseur non trouvé" });
    }

    res.status(200).json(fournisseur );
  } catch (error) {
    console.error("Erreur lors de la récupération du fournisseur", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// Mettre à jour un fournisseur
exports.mettreAJourFournisseur = async (req, res) => {
  try {
    const { id } = req.params;
    const { nomF, prenomF, entreprise, adresse, telephone, email, matricule, evaluation, notes, conditions_paiement, delai_livraison_moyen } = req.body;

    // Mettre à jour les informations du fournisseur par ID
    const fournisseur = await Fournisseur.findByIdAndUpdate(id, {
      nomF,
      prenomF,
      entreprise,
      adresse,
      telephone,
      email,
      matricule,
      evaluation,
      notes,
      conditions_paiement,
      delai_livraison_moyen
    }, { new: true });

    if (!fournisseur) {
      return res.status(404).json({ message: "Fournisseur non trouvé" });
    }

    res.status(200).json({ message: "Fournisseur mis à jour", fournisseur });
  } catch (error) {
    console.error("Erreur lors de la mise à jour du fournisseur", error);
    res.status(500).json({ error: "Erreur lors de la mise à jour du fournisseur" });
  }
};

// Supprimer un fournisseur
exports.supprimerFournisseur = async (req, res) => {
  try {
    const { id } = req.params;

    // Supprimer le fournisseur par ID
    const fournisseur = await Fournisseur.findByIdAndDelete(id);

    if (!fournisseur) {
      return res.status(404).json({ message: "Fournisseur non trouvé" });
    }

    res.status(204).send(); // No content
  } catch (error) {
    console.error("Erreur lors de la suppression du fournisseur", error);
    res.status(500).json({ error: "Erreur lors de la suppression du fournisseur" });
  }
};
