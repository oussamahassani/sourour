const bcrypt = require('bcrypt');
const Admin = require('../models/User'); // Le modèle Mongoose

// Ajouter un administrateur
exports.ajouterAdmin = async (req, res) => {
    try {
        const { nom, prenom, email, motDePasse, telephone,role } = req.body;

        const hash = await bcrypt.hash(motDePasse, 10);

        const nouvelAdmin = new Admin({ nom, prenom,role, email, motDePasse: hash, telephone });
        const adminSauvegarde = await nouvelAdmin.save();

        res.status(201).json({ message: "Admin ajouté avec succès", id: adminSauvegarde._id });
    } catch (error) {
        res.status(500).json({ message: "Erreur serveur", error });
    }
};

// Récupérer tous les administrateurs
exports.listerAdmins = async (req, res) => {
    try {
        const admins = await Admin.find();
        res.status(200).json(admins);
    } catch (error) {
        res.status(500).json({ message: "Erreur serveur", error });
    }
};

// Récupérer un administrateur par ID
exports.getAdminById = async (req, res) => {
    try {
        const { id } = req.params;
        const admin = await Admin.findById(id);

        if (!admin) return res.status(404).json({ message: "Admin non trouvé" });

        res.status(200).json(admin);
    } catch (error) {
        res.status(500).json({ message: "Erreur serveur", error });
    }
};

// Mettre à jour un administrateur
exports.updateAdmin = async (req, res) => {
    try {
        const { id } = req.params;
        const { nom, prenom, email, telephone } = req.body;

        const admin = await Admin.findByIdAndUpdate(id, { nom, prenom, email, telephone }, { new: true });

        if (!admin) return res.status(404).json({ message: "Admin non trouvé" });

        res.status(200).json({ message: "Admin mis à jour avec succès" });
    } catch (error) {
        res.status(500).json({ message: "Erreur serveur", error });
    }
};

// Supprimer un administrateur
exports.supprimerAdmin = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await Admin.findByIdAndDelete(id);

        if (!result) return res.status(404).json({ message: "Admin non trouvé" });

        res.status(200).json({ message: "Admin supprimé avec succès" });
    } catch (error) {
        res.status(500).json({ message: "Erreur serveur", error });
    }
};


