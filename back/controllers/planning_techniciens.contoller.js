const PlanningTechniciens = require('../models/planning_techniciens');

// Créer un planning pour un technicien
exports.createPlanning = async (req, res) => {
  try {
    const { idU, idCL, date_intervention, heure_debut, heure_fin, description_intervention, type_intervention, statut, priorite, adresse_intervention, id_equipement, recurrente, periodicite } = req.body;

    const newPlanning = await PlanningTechniciens.create({
      idU,
      idCL,
      date_intervention,
      heure_debut,
      heure_fin,
      description_intervention,
      type_intervention,
      statut,
      priorite,
      adresse_intervention,
      id_equipement,
      recurrente,
      periodicite
    });

    res.status(201).json(newPlanning);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Récupérer tous les plannings
exports.getAllPlannings = async (req, res) => {
  try {
    const plannings = await PlanningTechniciens.findAll();
    res.status(200).json(plannings);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Récupérer un planning par ID
exports.getPlanningById = async (req, res) => {
  try {
    const planning = await PlanningTechniciens.findByPk(req.params.id);

    if (!planning) {
      return res.status(404).json({ message: 'Planning non trouvé' });
    }

    res.status(200).json(planning);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Mettre à jour un planning
exports.updatePlanning = async (req, res) => {
  try {
    const planning = await PlanningTechniciens.findByPk(req.params.id);

    if (!planning) {
      return res.status(404).json({ message: 'Planning non trouvé' });
    }

    const updatedPlanning = await planning.update(req.body);
    res.status(200).json(updatedPlanning);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Supprimer un planning
exports.deletePlanning = async (req, res) => {
  try {
    const planning = await PlanningTechniciens.findByPk(req.params.id);

    if (!planning) {
      return res.status(404).json({ message: 'Planning non trouvé' });
    }

    await planning.destroy();
    res.status(200).json({ message: 'Planning supprimé' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
