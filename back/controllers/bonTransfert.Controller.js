// controllers/bonTransfertController.js
const BonTransfert = require('../models/BonTransfert');

// Ajouter un bon de transfert
exports.ajouterBonTransfert = async (req, res) => {
  try {
    const { id_entrepot_source, id_entrepot_destination, date_transfert, statut } = req.body;
    const newBonTransfert = new BonTransfert({
      id_entrepot_source,
      id_entrepot_destination,
      date_transfert,
      statut
    });

    await newBonTransfert.save();
    res.status(201).json({ message: 'Bon de transfert ajouté avec succès', bonTransfert: newBonTransfert });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de l\'ajout du bon de transfert' });
  }
};

// Lister tous les bons de transfert
exports.listerBonsTransfert = async (req, res) => {
  try {
    const bonsTransfert = await BonTransfert.find()
      .populate('id_entrepot_source', 'nom')
      .populate('id_entrepot_destination', 'nom');
    res.status(200).json({ bonsTransfert });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de la récupération des bons de transfert' });
  }
};

// Récupérer un bon de transfert par ID
exports.getBonTransfertById = async (req, res) => {
  try {
    const { id } = req.params;
    const bonTransfert = await BonTransfert.findById(id);

    if (!bonTransfert) {
      return res.status(404).json({ error: 'Bon de transfert non trouvé' });
    }

    res.status(200).json({ bonTransfert });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de la récupération du bon de transfert' });
  }
};

// Modifier un bon de transfert
exports.modifierBonTransfert = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedBonTransfert = await BonTransfert.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedBonTransfert) {
      return res.status(404).json({ error: 'Bon de transfert non trouvé' });
    }

    res.status(200).json({ message: 'Bon de transfert mis à jour avec succès', bonTransfert: updatedBonTransfert });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de la mise à jour du bon de transfert' });
  }
};

// Supprimer un bon de transfert
exports.supprimerBonTransfert = async (req, res) => {
  try {
    const { id } = req.params;
    const bonTransfert = await BonTransfert.findByIdAndDelete(id);

    if (!bonTransfert) {
      return res.status(404).json({ error: 'Bon de transfert non trouvé' });
    }

    res.status(200).json({ message: 'Bon de transfert supprimé avec succès' });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur lors de la suppression du bon de transfert' });
  }
};
