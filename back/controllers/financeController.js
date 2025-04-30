const Finance = require('../models/finance');

// 📌 Ajouter un mouvement financier
exports.ajouterMouvement = async (req, res) => {
  try {
    const { id_bordereau, situation_comptes, mouvement_financier, date_mouvement, description, id_compte, type_mouvement } = req.body;

    const newMouvement = new Finance({
      id_bordereau,
      situation_comptes,
      mouvement_financier,
      date_mouvement,
      description,
      id_compte,
      type_mouvement
    });

    await newMouvement.save();
    res.status(201).json({ message: 'Mouvement financier ajouté avec succès', mouvement: newMouvement });
  } catch (error) {
    console.error("Erreur lors de l'ajout du mouvement financier :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout du mouvement financier" });
  }
};

// 📌 Lister tous les mouvements financiers
exports.listerMouvements = async (req, res) => {
  try {
    const mouvements = await Finance.find().populate('id_bordereau id_compte');
    res.status(200).json({ mouvements });
  } catch (error) {
    console.error("Erreur lors de la récupération des mouvements financiers :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des mouvements financiers" });
  }
};

// 📌 Récupérer un mouvement financier par ID
exports.getMouvementById = async (req, res) => {
  try {
    const { id } = req.params;
    const mouvement = await Finance.findById(id).populate('id_bordereau id_compte');

    if (!mouvement) {
      return res.status(404).json({ error: "Mouvement financier non trouvé" });
    }

    res.status(200).json({ mouvement });
  } catch (error) {
    console.error("Erreur lors de la récupération du mouvement financier :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// 📌 Modifier un mouvement financier
exports.modifierMouvement = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedMouvement = await Finance.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedMouvement) {
      return res.status(404).json({ error: "Mouvement financier non trouvé" });
    }

    res.status(200).json({ message: "Mouvement financier mis à jour avec succès", mouvement: updatedMouvement });
  } catch (error) {
    console.error("Erreur lors de la mise à jour du mouvement financier :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour du mouvement financier" });
  }
};

// 📌 Supprimer un mouvement financier
exports.supprimerMouvement = async (req, res) => {
  try {
    const { id } = req.params;
    const mouvement = await Finance.findByIdAndDelete(id);

    if (!mouvement) {
      return res.status(404).json({ error: "Mouvement financier non trouvé" });
    }

    res.status(200).json({ message: "Mouvement financier supprimé avec succès" });
  } catch (error) {
    console.error("Erreur lors de la suppression du mouvement financier :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression du mouvement financier" });
  }
};
