const PaiementVente = require('../models/PaiementVente');
const Client = require('../models/Client');

// Créer un nouveau paiement
exports.createPaiement = async (req, res) => {
  try {
    const { clientId, montantRecu, modePaiement, statut, datePaiement, description } = req.body;

    // Validation des données
    if (!clientId || !montantRecu || !modePaiement || !statut) {
      return res.status(400).json({ message: 'Tous les champs requis doivent être fournis' });
    }

    // Vérifier si le client existe
    const client = await Client.findOne({ idCL: clientId });
    if (!client) {
      return res.status(404).json({ message: 'Client non trouvé' });
    }

    // Vérifier le plafond de crédit du client (optionnel)
    if (client.plafond_credit > 0 && montantRecu > client.plafond_credit) {
      return res.status(400).json({ message: 'Le montant dépasse le plafond de crédit du client' });
    }

    const paiement = new PaiementVente({
      clientId,
      montantRecu,
      modePaiement,
      statut,
      datePaiement: datePaiement || Date.now(),
      description
    });

    await paiement.save();
    res.status(201).json({ message: 'Paiement créé avec succès', paiement });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

// Récupérer tous les paiements
exports.getAllPaiements = async (req, res) => {
  try {
    const paiements = await PaiementVente.find().populate('clientId', 'nom prenom entreprise email');
    res.status(200).json(paiements);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

// Récupérer les paiements d'un client spécifique
exports.getPaiementsByClient = async (req, res) => {
  try {
    const paiements = await PaiementVente.find({ clientId: req.params.clientId }).populate('clientId', 'nom prenom entreprise email');
    if (!paiements.length) {
      return res.status(404).json({ message: 'Aucun paiement trouvé pour ce client' });
    }
    res.status(200).json(paiements);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

// Récupérer un paiement par ID
exports.getPaiementById = async (req, res) => {
  try {
    const paiement = await PaiementVente.findOne({ idPaiement: req.params.id }).populate('clientId', 'nom prenom entreprise email');
    if (!paiement) {
      return res.status(404).json({ message: 'Paiement non trouvé' });
    }
    res.status(200).json(paiement);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

// Mettre à jour un paiement
exports.updatePaiement = async (req, res) => {
  try {
    const { clientId, montantRecu, modePaiement, statut, datePaiement, description } = req.body;

    const paiement = await PaiementVente.findOne({ idPaiement: req.params.id });
    if (!paiement) {
      return res.status(404).json({ message: 'Paiement non trouvé' });
    }

    if (clientId) {
      const client = await Client.findOne({ idCL: clientId });
      if (!client) {
        return res.status(404).json({ message: 'Client non trouvé' });
      }
      paiement.clientId = clientId;
    }

    paiement.montantRecu = montantRecu || paiement.montantRecu;
    paiement.modePaiement = modePaiement || paiement.modePaiement;
    paiement.statut = statut || paiement.statut;
    paiement.datePaiement = datePaiement || paiement.datePaiement;
    paiement.description = description !== undefined ? description : paiement.description;

    await paiement.save();
    res.status(200).json({ message: 'Paiement mis à jour avec succès', paiement });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

// Supprimer un paiement
exports.deletePaiement = async (req, res) => {
  try {
    const paiement = await PaiementVente.findOneAndDelete({ idPaiement: req.params.id });
    if (!paiement) {
      return res.status(404).json({ message: 'Paiement non trouvé' });
    }
    res.status(200).json({ message: 'Paiement supprimé avec succès' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

module.exports = exports;
