const Encaissement = require('../models/encaissement');

// 📌 Ajouter un encaissement
exports.ajouterEncaissement = async (req, res) => {
  try {
    const { id_facture, id_client, montant, mode_paiement, date_encaissement, utilisateur_encaissement, commentaire } = req.body;

    const newEncaissement = new Encaissement({
      id_facture,
      id_client,
      montant,
      mode_paiement,
      date_encaissement,
      utilisateur_encaissement,
      commentaire
    });

    await newEncaissement.save();
    res.status(201).json({ message: 'Encaissement ajouté avec succès', encaissement: newEncaissement });
  } catch (error) {
    console.error("Erreur lors de l'ajout de l'encaissement :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout de l'encaissement" });
  }
};

// 📌 Lister tous les encaissements
exports.listerEncaissements = async (req, res) => {
  try {
    const encaissements = await Encaissement.find()
      .populate('id_facture', 'titre')
      .populate('id_client', 'nom')
      .populate('utilisateur_encaissement', 'nom');
    
    res.status(200).json({ encaissements });
  } catch (error) {
    console.error("Erreur lors de la récupération des encaissements :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des encaissements" });
  }
};

// 📌 Récupérer un encaissement par ID
exports.getEncaissementById = async (req, res) => {
  try {
    const { id } = req.params;
    const encaissement = await Encaissement.findById(id)
      .populate('id_facture', 'titre')
      .populate('id_client', 'nom')
      .populate('utilisateur_encaissement', 'nom');

    if (!encaissement) {
      return res.status(404).json({ error: "Encaissement non trouvé" });
    }

    res.status(200).json({ encaissement });
  } catch (error) {
    console.error("Erreur lors de la récupération de l'encaissement :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// 📌 Modifier un encaissement
exports.modifierEncaissement = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedEncaissement = await Encaissement.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedEncaissement) {
      return res.status(404).json({ error: "Encaissement non trouvé" });
    }

    res.status(200).json({ message: "Encaissement mis à jour avec succès", encaissement: updatedEncaissement });
  } catch (error) {
    console.error("Erreur lors de la mise à jour de l'encaissement :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour de l'encaissement" });
  }
};

// 📌 Supprimer un encaissement
exports.supprimerEncaissement = async (req, res) => {
  try {
    const { id } = req.params;
    const encaissement = await Encaissement.findByIdAndDelete(id);

    if (!encaissement) {
      return res.status(404).json({ error: "Encaissement non trouvé" });
    }

    res.status(200).json({ message: "Encaissement supprimé avec succès" });
  } catch (error) {
    console.error("Erreur lors de la suppression de l'encaissement :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression de l'encaissement" });
  }
};
