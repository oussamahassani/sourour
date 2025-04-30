const Client = require('../models/Client');

// 📌 Ajouter un client
exports.ajouterClient = async (req, res) => {
  try {
    const {
      nom, prenom, email, telephone, adresse,
      plafond_credit, validation_admin, entreprise,
      matricule, cin, commercial_assigne
    } = req.body;

    const newClient = new Client({
      nom,
      prenom,
      email,
      telephone,
      adresse,
      plafond_credit,
      validation_admin,
      entreprise,
      matricule,
      cin,
      commercial_assigne
    });

    await newClient.save();
    res.status(201).json({ message: 'Client ajouté avec succès', client: newClient });
  } catch (error) {
    console.error("Erreur lors de l'ajout du client :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout du client" });
  }
};

// 📌 Lister tous les clients
exports.listerClients = async (req, res) => {
  try {
    const clients = await Client.find().populate('commercial_assigne', 'nom prenom');
    res.status(200).json({ clients });
  } catch (error) {
    console.error("Erreur lors de la récupération des clients :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des clients" });
  }
};

// 📌 Récupérer un client par ID
exports.getClientById = async (req, res) => {
  try {
    const { id } = req.params;
    const client = await Client.findById(id).populate('commercial_assigne', 'nom prenom');

    if (!client) {
      return res.status(404).json({ error: "Client non trouvé" });
    }

    res.status(200).json({ client });
  } catch (error) {
    console.error("Erreur lors de la récupération du client :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// 📌 Modifier un client
exports.modifierClient = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedClient = await Client.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedClient) {
      return res.status(404).json({ error: "Client non trouvé" });
    }

    res.status(200).json({ message: "Client mis à jour avec succès", client: updatedClient });
  } catch (error) {
    console.error("Erreur lors de la mise à jour du client :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour du client" });
  }
};

// 📌 Supprimer un client
exports.supprimerClient = async (req, res) => {
  try {
    const { id } = req.params;
    const client = await Client.findByIdAndDelete(id);

    if (!client) {
      return res.status(404).json({ error: "Client non trouvé" });
    }

    res.status(200).json({ message: "Client supprimé avec succès" });
  } catch (error) {
    console.error("Erreur lors de la suppression du client :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression du client" });
  }
};
