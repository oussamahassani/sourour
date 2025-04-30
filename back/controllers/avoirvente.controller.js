const AvoirVente = require('../models/AvoirVente');
const Vente = require('../models/Vente');  // Assurez-vous d'avoir ce modèle
const Client = require('../models/Client');  // Assurez-vous d'avoir ce modèle

// Ajouter un avoir sur vente
exports.ajouterAvoirVente = async (req, res) => {
  try {
    const { id_vente, id_client, montant_avoir, date_avoir, statut } = req.body;

    // Vérifier l'existence de la vente et du client
    const venteExiste = await Vente.findById(id_vente);
    const clientExiste = await Client.findById(id_client);

    if (!venteExiste) return res.status(404).json({ error: "Vente non trouvée" });
    if (!clientExiste) return res.status(404).json({ error: "Client non trouvé" });

    const newAvoirVente = new AvoirVente({
      id_vente,
      id_client,
      montant_avoir,
      date_avoir,
      statut
    });

    await newAvoirVente.save();
    res.status(201).json({ message: "Avoir ajouté avec succès", avoirVente: newAvoirVente });
  } catch (error) {
    console.error("Erreur lors de l'ajout de l'avoir sur vente :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout de l'avoir sur vente" });
  }
};

// Lister tous les avoirs sur vente
exports.listeAvoirsVente = async (req, res) => {
  try {
    const avoirsVente = await AvoirVente.find()
      .populate('id_vente', 'num_vente montant_total') // Récupérer les infos de la vente
      .populate('id_client', 'nom') // Récupérer les infos du client

    res.status(200).json({ avoirsVente });
  } catch (error) {
    console.error("Erreur lors de la récupération des avoirs sur vente :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des avoirs sur vente" });
  }
};

// Récupérer un avoir sur vente par ID
exports.getAvoirVenteById = async (req, res) => {
  try {
    const { id } = req.params;
    const avoirVente = await AvoirVente.findById(id)
      .populate('id_vente', 'num_vente montant_total')
      .populate('id_client', 'nom');

    if (!avoirVente) {
      return res.status(404).json({ error: "Avoir non trouvé" });
    }

    res.status(200).json({ avoirVente });
  } catch (error) {
    console.error("Erreur lors de la récupération de l'avoir sur vente :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// Modifier un avoir sur vente
exports.modifierAvoirVente = async (req, res) => {
  try {
    const { id } = req.params;

    const updatedAvoirVente = await AvoirVente.findByIdAndUpdate(id, req.body, { new: true, runValidators: true })
      .populate('id_vente', 'num_vente')
      .populate('id_client', 'nom');

    if (!updatedAvoirVente) {
      return res.status(404).json({ error: "Avoir non trouvé" });
    }

    res.status(200).json({ message: "Avoir mis à jour avec succès", avoirVente: updatedAvoirVente });
  } catch (error) {
    console.error("Erreur lors de la mise à jour de l'avoir sur vente :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour de l'avoir sur vente" });
  }
};

// Supprimer un avoir sur vente
exports.supprimerAvoirVente = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedAvoirVente = await AvoirVente.findByIdAndDelete(id);

    if (!deletedAvoirVente) {
      return res.status(404).json({ error: "Avoir non trouvé" });
    }

    res.status(200).json({ message: "Avoir supprimé avec succès" });
  } catch (error) {
    console.error("Erreur lors de la suppression de l'avoir sur vente :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression de l'avoir sur vente" });
  }
};
