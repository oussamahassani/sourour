const Permission = require('../models/Permissions');

// Ajouter une permission
exports.ajouterPermission = async (req, res) => {
    try {
        const permission = new Permission(req.body);
        await permission.save();
        res.status(201).json({ message: "Permission ajoutée avec succès", permission });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de l'ajout de la permission", error });
    }
};

// Récupérer toutes les permissions
exports.getAllPermissions = async (req, res) => {
    try {
        const permissions = await Permission.find();
        res.status(200).json(permissions);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de la récupération des permissions", error });
    }
};

// Récupérer une permission par ID
exports.getPermissionById = async (req, res) => {
    try {
        const permission = await Permission.findById(req.params.id);
        if (!permission) {
            return res.status(404).json({ message: "Permission non trouvée" });
        }
        res.status(200).json(permission);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de la récupération de la permission", error });
    }
};

// Mettre à jour une permission
exports.updatePermission = async (req, res) => {
    try {
        const permission = await Permission.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!permission) {
            return res.status(404).json({ message: "Permission non trouvée" });
        }
        res.status(200).json({ message: "Permission mise à jour", permission });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de la mise à jour de la permission", error });
    }
};

// Supprimer une permission
exports.deletePermission = async (req, res) => {
    try {
        const permission = await Permission.findByIdAndDelete(req.params.id);
        if (!permission) {
            return res.status(404).json({ message: "Permission non trouvée" });
        }
        res.status(200).json({ message: "Permission supprimée avec succès" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur lors de la suppression de la permission", error });
    }
};
