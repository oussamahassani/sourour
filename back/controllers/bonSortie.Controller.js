const BonSortie = require('../models/BonSortie');

// Ajouter un bon de sortie
exports.ajouterBonSortie = async (req, res) => {
  try {
    const { numero_BS, id_utilisateur, date_sortie, motif, commentaire } = req.body;
    const newBonSortie = new BonSortie({
      numero_BS,
      id_utilisateur,
      date_sortie,
      motif,
      commentaire
    });

    await newBonSortie.save();
    res.status(201).json({ message: 'Bon de sortie ajouté avec succès', bonSortie: newBonSortie });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de l\'ajout du bon de sortie' });
  }
};

// Lister tous les bons de sortie
exports.listerBonsSortie = async (req, res) => {
  try {
    const bonsSortie = await BonSortie.find().populate('id_utilisateur', 'nom');
    res.status(200).json({ bonsSortie });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de la récupération des bons de sortie' });
  }
};

// Récupérer un bon de sortie par ID
exports.getBonSortieById = async (req, res) => {
  try {
    const { id } = req.params;
    const bonSortie = await BonSortie.findById(id);

    if (!bonSortie) {
      return res.status(404).json({ error: 'Bon de sortie non trouvé' });
    }

    res.status(200).json({ bonSortie });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de la récupération du bon de sortie' });
  }
};

// Modifier un bon de sortie
exports.modifierBonSortie = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedBonSortie = await BonSortie.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedBonSortie) {
      return res.status(404).json({ error: 'Bon de sortie non trouvé' });
    }

    res.status(200).json({ message: 'Bon de sortie mis à jour avec succès', bonSortie: updatedBonSortie });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de la mise à jour du bon de sortie' });
  }
};

// Supprimer un bon de sortie
exports.supprimerBonSortie = async (req, res) => {
  try {
    const { id } = req.params;
    const bonSortie = await BonSortie.findByIdAndDelete(id);

    if (!bonSortie) {
      return res.status(404).json({ error: 'Bon de sortie non trouvé' });
    }

    res.status(200).json({ message: 'Bon de sortie supprimé avec succès' });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de la suppression du bon de sortie' });
  }
};
