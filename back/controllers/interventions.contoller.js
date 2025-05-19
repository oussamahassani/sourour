const Intervention = require('../models/Interventions');
const InterventionRepport = require('../models/Rapportintervention');

const Client = require('../models/Client');


// Ajouter une intervention
exports.ajouterInterventionRepport= async (req, res) => {
  try {

    // Créer une nouvelle InterventionRepport
    const intervention = new InterventionRepport(req.body);

    // Sauvegarder l'intervention dans la base de données
    await intervention.save();
    res.status(201).json({ message: "Intervention report ajoutée avec succès", intervention });
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de l'ajout de l'intervention" });
  }
}

// Supprimer une intervention
exports.supprimerInterventionRepport = async (req, res) => {
  try {
    const { id } = req.params;

    const intervention = await InterventionRepport.findByIdAndDelete(id);

    if (!intervention) {
      return res.status(404).json({ message: "Intervention non trouvée" });
    }

    res.status(204).send(); // No content
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de la suppression de l'intervention" });
  }
};
exports.getoneInterventionRepport = async (req, res) => {
  try {
    const { id } = req.params;

    const intervention = await InterventionRepport.findById(id )
   

  
    res.status(200).json({ message: "Intervention mise à jour avec succès", intervention });
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de la mise à jour de l'intervention" });
  }
};
exports.mettreAJourInterventionRepport = async (req, res) => {
  try {
    const { id } = req.params;

    const intervention = await InterventionRepport.findByIdAndUpdate(id,req.body )
   

  
    res.status(200).json({ message: "Intervention mise à jour avec succès", intervention });
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de la mise à jour de l'intervention" });
  }
};
exports.listeInterventionRepport= async (req, res) => {
  try {
    const interventions = await InterventionRepport.find();
    res.status(200).json(interventions);
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de la récupération des interventions" });
  }
};
exports.ajouterIntervention = async (req, res) => {
  try {
    const { idPL, date_intervention, description, statut, rapport_intervention, duree_reelle, id_technicien, signature_client, commentaires_client } = req.body;

    // Créer une nouvelle intervention
    const intervention = new Intervention({
      idPL,
      date_intervention,
      description,
      statut,
      rapport_intervention,
      duree_reelle,
      id_technicien,
      signature_client,
      commentaires_client
    });

    // Sauvegarder l'intervention dans la base de données
    await intervention.save();
    res.status(201).json({ message: "Intervention ajoutée avec succès", intervention });
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de l'ajout de l'intervention" });
  }
};

// Lister toutes les interventions
exports.listeInterventions = async (req, res) => {
  try {
    const interventions = await Intervention.find();
    res.status(200).json({ interventions });
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de la récupération des interventions" });
  }
};

// Mettre à jour une intervention
exports.mettreAJourIntervention = async (req, res) => {
  try {
    const { id } = req.params;
    const { idPL, date_intervention, description, statut, rapport_intervention, duree_reelle, id_technicien, signature_client, commentaires_client } = req.body;

    const intervention = await Intervention.findByIdAndUpdate(id, {
      idPL,
      date_intervention,
      description,
      statut,
      rapport_intervention,
      duree_reelle,
      id_technicien,
      signature_client,
      commentaires_client
    }, { new: true });

    if (!intervention) {
      return res.status(404).json({ message: "Intervention non trouvée" });
    }

    res.status(200).json({ message: "Intervention mise à jour avec succès", intervention });
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de la mise à jour de l'intervention" });
  }
};

// Supprimer une intervention
exports.supprimerIntervention = async (req, res) => {
  try {
    const { id } = req.params;

    const intervention = await Intervention.findByIdAndDelete(id);

    if (!intervention) {
      return res.status(404).json({ message: "Intervention non trouvée" });
    }

    res.status(204).send(); // No content
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de la suppression de l'intervention" });
  }
};
