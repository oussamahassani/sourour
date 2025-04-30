const Admin = require('../models/Admin');
// Ajouter un administrateur
exports.ajouterAdmin = (req, res) => {
    const { nom, prenom, email, mdp, telephone } = req.body;
    
    // Hachage du mot de passe avant stockage
    bcrypt.hash(mdp, 10, (err, hash) => {
        if (err) return res.status(500).json({ message: "Erreur de hachage" });

        Admin.ajouter(nom, prenom, email, hash, telephone, (error, result) => {
            if (error) return res.status(500).json({ message: "Erreur serveur", error });
            res.status(201).json({ message: "Admin ajouté avec succès", id: result.insertId });
        });
    });
};

// Récupérer tous les administrateurs
exports.listerAdmins = (req, res) => {
    Admin.lister((error, result) => {
        if (error) return res.status(500).json({ message: "Erreur serveur", error });
        res.status(200).json(result);
    });
};

// Récupérer un administrateur par ID
exports.getAdminById = (req, res) => {
    const { id } = req.params;
    Admin.trouverParId(id, (error, result) => {
        if (error) return res.status(500).json({ message: "Erreur serveur", error });
        if (result.length === 0) return res.status(404).json({ message: "Admin non trouvé" });
        res.status(200).json(result[0]);
    });
};

// Mettre à jour un administrateur
exports.updateAdmin = (req, res) => {
    const { id } = req.params;
    const { nom, prenom, email, telephone } = req.body;
    
    Admin.mettreAJour(id, nom, prenom, email, telephone, (error, result) => {
        if (error) return res.status(500).json({ message: "Erreur serveur", error });
        res.status(200).json({ message: "Admin mis à jour avec succès" });
    });
};

// Supprimer un administrateur
exports.supprimerAdmin = (req, res) => {
    const { id } = req.params;
    
    Admin.supprimer(id, (error, result) => {
        if (error) return res.status(500).json({ message: "Erreur serveur", error });
        res.status(200).json({ message: "Admin supprimé avec succès" });
    });
};
