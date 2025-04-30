const Mouvement = require('../models/Mouvements_stock'); // Assurez-vous que ce chemin est correct

// Ajouter un mouvement
exports.ajouterMouvement = async (req, res) => {
  try {
    const { id_article, type_mouvement, quantite, id_utilisateur, reference_document, type_document, motif } = req.body;

    // Créer un nouveau mouvement
    const mouvement = new Mouvement({
      id_article,
      type_mouvement,
      quantite,
      id_utilisateur,
      reference_document,
      type_document,
      motif
    });

    // Sauvegarder le mouvement dans la base de données
    await mouvement.save();
    res.status(201).json({ message: "Mouvement ajouté avec succès", mouvement });
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de l'ajout du mouvement" });
  }
};

// Lister tous les mouvements
exports.listerMouvements = async (req, res) => {
  try {
    const mouvements = await Mouvement.find();
    res.status(200).json({ mouvements });
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de la récupération des mouvements" });
  }
};

// Mettre à jour un mouvement
exports.mettreAJourMouvement = async (req, res) => {
  try {
    const { id } = req.params;
    const { id_article, type_mouvement, quantite, id_utilisateur, reference_document, type_document, motif } = req.body;

    const mouvement = await Mouvement.findByIdAndUpdate(id, {
      id_article,
      type_mouvement,
      quantite,
      id_utilisateur,
      reference_document,
      type_document,
      motif
    }, { new: true });

    if (!mouvement) {
      return res.status(404).json({ message: "Mouvement non trouvé" });
    }

    res.status(200).json({ message: "Mouvement mis à jour avec succès", mouvement });
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de la mise à jour du mouvement" });
  }
};

// Supprimer un mouvement
exports.supprimerMouvement = async (req, res) => {
  try {
    const { id } = req.params;

    const mouvement = await Mouvement.findByIdAndDelete(id);

    if (!mouvement) {
      return res.status(404).json({ message: "Mouvement non trouvé" });
    }

    res.status(204).send(); // No content
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de la suppression du mouvement" });
  }
};
