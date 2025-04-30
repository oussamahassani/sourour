// controllers/bordereauController.js
const Bordereau = require('../models/bordereau');

// Ajouter un bordereau
exports.ajouterBordereau = async (req, res) => {
  try {
    const { num_bordereau, type_bordereau, date_bordereau, montant, id_document } = req.body;
    const newBordereau = new Bordereau({
      num_bordereau,
      type_bordereau,
      date_bordereau,
      montant,
      id_document
    });

    await newBordereau.save();
    res.status(201).json({ message: 'Bordereau ajouté avec succès', bordereau: newBordereau });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de l\'ajout du bordereau' });
  }
};

// Lister tous les bordereaux
exports.listerBordereaux = async (req, res) => {
  try {
    const bordereaux = await Bordereau.find().populate('id_document', 'type_document');
    res.status(200).json({ bordereaux });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de la récupération des bordereaux' });
  }
};

// Récupérer un bordereau par ID
exports.getBordereauById = async (req, res) => {
  try {
    const { id } = req.params;
    const bordereau = await Bordereau.findById(id);

    if (!bordereau) {
      return res.status(404).json({ error: 'Bordereau non trouvé' });
    }

    res.status(200).json({ bordereau });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de la récupération du bordereau' });
  }
};

// Modifier un bordereau
exports.modifierBordereau = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedBordereau = await Bordereau.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedBordereau) {
      return res.status(404).json({ error: 'Bordereau non trouvé' });
    }

    res.status(200).json({ message: 'Bordereau mis à jour avec succès', bordereau: updatedBordereau });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de la mise à jour du bordereau' });
  }
};

// Supprimer un bordereau
exports.supprimerBordereau = async (req, res) => {
  try {
    const { id } = req.params;
    const bordereau = await Bordereau.findByIdAndDelete(id);

    if (!bordereau) {
      return res.status(404).json({ error: 'Bordereau non trouvé' });
    }

    res.status(200).json({ message: 'Bordereau supprimé avec succès' });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de la suppression du bordereau' });
  }
};
