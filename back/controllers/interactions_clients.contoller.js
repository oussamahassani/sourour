const Interaction = require('../models/Interactions_clients'); // Assurez-vous que le chemin est correct

// Ajouter une interaction
exports.ajouterInteraction = async (req, res) => {
  try {
    const { id_client, id_utilisateur, date_interaction, type_interaction, description, suivi_requis, date_suivi } = req.body;

    const interaction = new Interaction({
      id_client,
      id_utilisateur,
      date_interaction,
      type_interaction,
      description,
      suivi_requis,
      date_suivi
    });

    await interaction.save();
    res.status(201).json({ message: 'Interaction ajoutée avec succès', interaction });
  } catch (error) {
    console.error('Erreur lors de l\'ajout de l\'interaction', error);
    res.status(500).json({ error: 'Erreur serveur lors de l\'ajout de l\'interaction' });
  }
};

// Lister toutes les interactions
exports.listerInteractions = async (req, res) => {
  try {
    const interactions = await Interaction.find();
    res.status(200).json({ interactions });
  } catch (error) {
    console.error('Erreur lors de la récupération des interactions', error);
    res.status(500).json({ error: 'Erreur serveur lors de la récupération des interactions' });
  }
};

// Récupérer une interaction par ID
exports.getInteractionById = async (req, res) => {
  try {
    const { id } = req.params;
    const interaction = await Interaction.findById(id);

    if (!interaction) {
      return res.status(404).json({ error: 'Interaction non trouvée' });
    }

    res.status(200).json({ interaction });
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'interaction', error);
    res.status(500).json({ error: 'Erreur serveur lors de la récupération de l\'interaction' });
  }
};

// Mettre à jour une interaction
exports.mettreAJourInteraction = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedInteraction = await Interaction.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedInteraction) {
      return res.status(404).json({ error: 'Interaction non trouvée' });
    }

    res.status(200).json({ message: 'Interaction mise à jour', interaction: updatedInteraction });
  } catch (error) {
    console.error('Erreur lors de la mise à jour de l\'interaction', error);
    res.status(500).json({ error: 'Erreur serveur lors de la mise à jour de l\'interaction' });
  }
};

// Supprimer une interaction
exports.supprimerInteraction = async (req, res) => {
  try {
    const { id } = req.params;
    const interaction = await Interaction.findByIdAndDelete(id);

    if (!interaction) {
      return res.status(404).json({ error: 'Interaction non trouvée' });
    }

    res.status(200).json({ message: 'Interaction supprimée avec succès' });
  } catch (error) {
    console.error('Erreur lors de la suppression de l\'interaction', error);
    res.status(500).json({ error: 'Erreur serveur lors de la suppression de l\'interaction' });
  }
};
