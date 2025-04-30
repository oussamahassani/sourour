const FicheBaie = require('../models/ficheBaie');

// 📌 Ajouter une fiche baie
exports.ajouterFicheBaie = async (req, res) => {
  try {
    const { nom_baie, emplacement, capacite, type_baie, statut } = req.body;

    const newFicheBaie = new FicheBaie({
      nom_baie,
      emplacement,
      capacite,
      type_baie,
      statut
    });

    await newFicheBaie.save();
    res.status(201).json({ message: 'Fiche baie ajoutée avec succès', ficheBaie: newFicheBaie });
  } catch (error) {
    console.error("Erreur lors de l'ajout de la fiche baie :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout de la fiche baie" });
  }
};

// 📌 Lister toutes les fiches baies
exports.listerFichesBaies = async (req, res) => {
  try {
    const fichesBaies = await FicheBaie.find();
    res.status(200).json({ fichesBaies });
  } catch (error) {
    console.error("Erreur lors de la récupération des fiches baies :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des fiches baies" });
  }
};

// 📌 Récupérer une fiche baie par ID
exports.getFicheBaieById = async (req, res) => {
  try {
    const { id } = req.params;
    const ficheBaie = await FicheBaie.findById(id);

    if (!ficheBaie) {
      return res.status(404).json({ error: "Fiche baie non trouvée" });
    }

    res.status(200).json({ ficheBaie });
  } catch (error) {
    console.error("Erreur lors de la récupération de la fiche baie :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// 📌 Modifier une fiche baie
exports.modifierFicheBaie = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedFicheBaie = await FicheBaie.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedFicheBaie) {
      return res.status(404).json({ error: "Fiche baie non trouvée" });
    }

    res.status(200).json({ message: "Fiche baie mise à jour avec succès", ficheBaie: updatedFicheBaie });
  } catch (error) {
    console.error("Erreur lors de la mise à jour de la fiche baie :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour de la fiche baie" });
  }
};

// 📌 Supprimer une fiche baie
exports.supprimerFicheBaie = async (req, res) => {
  try {
    const { id } = req.params;
    const ficheBaie = await FicheBaie.findByIdAndDelete(id);

    if (!ficheBaie) {
      return res.status(404).json({ error: "Fiche baie non trouvée" });
    }

    res.status(200).json({ message: "Fiche baie supprimée avec succès" });
  } catch (error) {
    console.error("Erreur lors de la suppression de la fiche baie :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression de la fiche baie" });
  }
};
