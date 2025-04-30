const Audit = require('../models/journal_audit');

// Ajouter un audit
exports.ajouterAudit = async (req, res) => {
  try {
    const { id_utilisateur, action, table_concernee, id_enregistrement, ancienne_valeur, nouvelle_valeur, adresse_ip } = req.body;

    // Créer un nouvel audit
    const audit = new Audit({
      id_utilisateur,
      action,
      table_concernee,
      id_enregistrement,
      ancienne_valeur,
      nouvelle_valeur,
      adresse_ip
    });

    // Sauvegarder l'audit dans la base de données
    await audit.save();
    res.status(201).json({ message: "Audit ajouté avec succès", audit });
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de l'ajout de l'audit" });
  }
};

// Lister tous les audits
exports.listeAudits = async (req, res) => {
  try {
    // Récupérer tous les audits
    const audits = await Audit.find();

    res.status(200).json({ audits });
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ error: "Erreur lors de la récupération des audits" });
  }
};
