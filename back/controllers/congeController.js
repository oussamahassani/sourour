const Conge = require('../models/Conge');

// 📌 Ajouter une demande de congé
exports.ajouterConge = async (req, res) => {
  try {
    const { id_employee, date_debut, date_fin, type_conge, motif } = req.body;

    const newConge = new Conge({
      id_employee,
      date_debut,
      date_fin,
      type_conge,
      motif
    });

    await newConge.save();
    res.status(201).json({ message: 'Demande de congé ajoutée avec succès', conge: newConge });
  } catch (error) {
    console.error("Erreur lors de l'ajout du congé :", error);
    res.status(500).json({ error: "Erreur serveur lors de la création de la demande de congé" });
  }
};

// 📌 Lister toutes les demandes de congé
exports.listerConges = async (req, res) => {
  try {
    const conges = await Conge.find().populate('id_employee', 'nom prenom');
    res.status(200).json({ conges });
  } catch (error) {
    console.error("Erreur lors de la récupération des congés :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des congés" });
  }
};

// 📌 Récupérer une demande de congé par ID
exports.getCongeById = async (req, res) => {
  try {
    const { id } = req.params;
    const conge = await Conge.findById(id).populate('id_employee', 'nom prenom');

    if (!conge) {
      return res.status(404).json({ error: "Demande de congé non trouvée" });
    }

    res.status(200).json({ conge });
  } catch (error) {
    console.error("Erreur lors de la récupération du congé :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// 📌 Modifier une demande de congé
exports.modifierConge = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedConge = await Conge.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedConge) {
      return res.status(404).json({ error: "Demande de congé non trouvée" });
    }

    res.status(200).json({ message: "Demande de congé mise à jour avec succès", conge: updatedConge });
  } catch (error) {
    console.error("Erreur lors de la mise à jour du congé :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour de la demande de congé" });
  }
};

// 📌 Supprimer une demande de congé
exports.supprimerConge = async (req, res) => {
  try {
    const { id } = req.params;
    const conge = await Conge.findByIdAndDelete(id);

    if (!conge) {
      return res.status(404).json({ error: "Demande de congé non trouvée" });
    }

    res.status(200).json({ message: "Demande de congé supprimée avec succès" });
  } catch (error) {
    console.error("Erreur lors de la suppression du congé :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression de la demande de congé" });
  }
};

// 📌 Approuver ou refuser un congé
exports.changerStatutConge = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, approuve_par } = req.body;

    if (!['Approuvé', 'Refusé'].includes(status)) {
      return res.status(400).json({ error: "Statut invalide. Choisissez 'Approuvé' ou 'Refusé'." });
    }

    const conge = await Conge.findByIdAndUpdate(id, { status, approuve_par }, { new: true });

    if (!conge) {
      return res.status(404).json({ error: "Demande de congé non trouvée" });
    }

    res.status(200).json({ message: `Demande de congé ${status.toLowerCase()} avec succès`, conge });
  } catch (error) {
    console.error("Erreur lors de la mise à jour du statut du congé :", error);
    res.status(500).json({ error: "Erreur serveur lors du changement de statut du congé" });
  }
};
