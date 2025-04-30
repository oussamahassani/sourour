const Garantie = require('../models/Garanties_contrats'); 

// Ajouter une garantie
exports.ajouterGarantie = async (req, res) => {
  try {
    const { id_vente, id_article, id_client, date_debut, date_fin, type, description, intervalle_maintenance, prochaine_maintenance, conditions } = req.body;

    const nouvelleGarantie = new Garantie({
      id_vente,
      id_article,
      id_client,
      date_debut,
      date_fin,
      type,
      description,
      intervalle_maintenance,
      prochaine_maintenance,
      conditions
    });

    // Sauvegarder la garantie dans la base de données
    await nouvelleGarantie.save();
    res.status(201).json({ message: 'Garantie ajoutée avec succès', garantie: nouvelleGarantie });
  } catch (error) {
    console.error('Erreur lors de l\'ajout de la garantie', error);
    res.status(500).json({ error: 'Erreur serveur lors de l\'ajout de la garantie' });
  }
};

// Lister toutes les garanties
exports.listerGaranties = async (req, res) => {
  try {
    const garanties = await Garantie.find();
    res.status(200).json({ garanties });
  } catch (error) {
    console.error('Erreur lors de la récupération des garanties', error);
    res.status(500).json({ error: 'Erreur serveur lors de la récupération des garanties' });
  }
};

// Récupérer une garantie par ID
exports.getGarantieById = async (req, res) => {
  try {
    const { id } = req.params;
    const garantie = await Garantie.findById(id);

    if (!garantie) {
      return res.status(404).json({ error: 'Garantie non trouvée' });
    }

    res.status(200).json({ garantie });
  } catch (error) {
    console.error('Erreur lors de la récupération de la garantie', error);
    res.status(500).json({ error: 'Erreur serveur lors de la récupération de la garantie' });
  }
};

// Mettre à jour une garantie
exports.mettreAJourGarantie = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedGarantie = await Garantie.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedGarantie) {
      return res.status(404).json({ error: 'Garantie non trouvée' });
    }

    res.status(200).json({ message: 'Garantie mise à jour', garantie: updatedGarantie });
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la garantie', error);
    res.status(500).json({ error: 'Erreur serveur lors de la mise à jour de la garantie' });
  }
};

// Supprimer une garantie
exports.supprimerGarantie = async (req, res) => {
  try {
    const { id } = req.params;
    const garantie = await Garantie.findByIdAndDelete(id);

    if (!garantie) {
      return res.status(404).json({ error: 'Garantie non trouvée' });
    }

    res.status(200).json({ message: 'Garantie supprimée avec succès' });
  } catch (error) {
    console.error('Erreur lors de la suppression de la garantie', error);
    res.status(500).json({ error: 'Erreur serveur lors de la suppression de la garantie' });
  }
};
