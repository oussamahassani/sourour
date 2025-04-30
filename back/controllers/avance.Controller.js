const Avance = require('../models/Avance');
const Facture = require('../models/Facture');
const Client = require('../models/Client');

// Ajouter une avance
exports.ajouterAvance = async (req, res) => {
  try {
    const { id_facture, id_client, montant, date_avance, mode_paiement, commentaire } = req.body;

    // Vérification de l'existence de la facture et du client
    const factureExiste = await Facture.findById(id_facture);
    const clientExiste = await Client.findById(id_client);

    if (!factureExiste) return res.status(404).json({ error: "Facture non trouvée" });
    if (!clientExiste) return res.status(404).json({ error: "Client non trouvé" });

    if (montant <= 0) return res.status(400).json({ error: "Le montant doit être positif" });

    const newAvance = new Avance({ id_facture, id_client, montant, date_avance, mode_paiement, commentaire });
    await newAvance.save();

    res.status(201).json({ message: "Avance ajoutée avec succès", avance: newAvance });

  } catch (error) {
    console.error("Erreur lors de l'ajout de l'avance :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout de l'avance" });
  }
};

// Lister toutes les avances
exports.listeAvances = async (req, res) => {
  try {
    const avances = await Avance.find()
      .populate('id_facture', 'num_facture montant_total') // Récupère le numéro et le montant total de la facture
      .populate('id_client', 'nom email'); // Récupère le nom et l'email du client

    res.status(200).json({ avances });

  } catch (error) {
    console.error("Erreur lors de la récupération des avances :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des avances" });
  }
};

// Récupérer une avance par ID
exports.getAvanceById = async (req, res) => {
  try {
    const { id } = req.params;
    const avance = await Avance.findById(id)
      .populate('id_facture', 'num_facture montant_total')
      .populate('id_client', 'nom email');

    if (!avance) {
      return res.status(404).json({ error: "Avance non trouvée" });
    }

    res.status(200).json({ avance });

  } catch (error) {
    console.error("Erreur lors de la récupération de l'avance :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// Modifier une avance
exports.modifierAvance = async (req, res) => {
  try {
    const { id } = req.params;

    // Vérifier que le montant reste positif
    if (req.body.montant !== undefined && req.body.montant <= 0) {
      return res.status(400).json({ error: "Le montant doit être positif" });
    }

    const updatedAvance = await Avance.findByIdAndUpdate(id, req.body, { new: true, runValidators: true })
      .populate('id_facture', 'num_facture')
      .populate('id_client', 'nom');

    if (!updatedAvance) {
      return res.status(404).json({ error: "Avance non trouvée" });
    }

    res.status(200).json({ message: "Avance mise à jour avec succès", avance: updatedAvance });

  } catch (error) {
    console.error("Erreur lors de la mise à jour de l'avance :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour de l'avance" });
  }
};

// Supprimer une avance
exports.supprimerAvance = async (req, res) => {
  try {
    const { id } = req.params;
    const avance = await Avance.findByIdAndDelete(id);

    if (!avance) {
      return res.status(404).json({ error: "Avance non trouvée" });
    }

    res.status(200).json({ message: "Avance supprimée avec succès" });

  } catch (error) {
    console.error("Erreur lors de la suppression de l'avance :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression de l'avance" });
  }
};
