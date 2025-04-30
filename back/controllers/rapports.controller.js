const Rapport = require('../models/Rapports');

// Créer un rapport
exports.createRapport = async (req, res) => {
    try {
        const { titre, type_rapport, periode_debut, periode_fin, contenu, chemin_fichier, id_utilisateur, parametres, planification } = req.body;

        const rapport = await Rapport.create({
            titre,
            type_rapport,
            periode_debut,
            periode_fin,
            contenu,
            chemin_fichier,
            id_utilisateur,
            parametres,
            planification
        });

        res.status(201).json(rapport);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Erreur lors de la création du rapport', error });
    }
};

// Obtenir tous les rapports
exports.getAllRapports = async (req, res) => {
    try {
        const rapports = await Rapport.findAll();
        res.status(200).json(rapports);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Erreur lors de la récupération des rapports', error });
    }
};

// Obtenir un rapport par son ID
exports.getRapportById = async (req, res) => {
    try {
        const rapport = await Rapport.findByPk(req.params.id_rapport);

        if (!rapport) {
            return res.status(404).json({ message: 'Rapport non trouvé' });
        }

        res.status(200).json(rapport);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Erreur lors de la récupération du rapport', error });
    }
};

// Mettre à jour un rapport
exports.updateRapport = async (req, res) => {
    try {
        const { titre, type_rapport, periode_debut, periode_fin, contenu, chemin_fichier, id_utilisateur, parametres, planification } = req.body;

        const rapport = await Rapport.findByPk(req.params.id_rapport);

        if (!rapport) {
            return res.status(404).json({ message: 'Rapport non trouvé' });
        }

        rapport.titre = titre || rapport.titre;
        rapport.type_rapport = type_rapport || rapport.type_rapport;
        rapport.periode_debut = periode_debut || rapport.periode_debut;
        rapport.periode_fin = periode_fin || rapport.periode_fin;
        rapport.contenu = contenu || rapport.contenu;
        rapport.chemin_fichier = chemin_fichier || rapport.chemin_fichier;
        rapport.id_utilisateur = id_utilisateur || rapport.id_utilisateur;
        rapport.parametres = parametres || rapport.parametres;
        rapport.planification = planification || rapport.planification;

        await rapport.save();

        res.status(200).json(rapport);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Erreur lors de la mise à jour du rapport', error });
    }
};

// Supprimer un rapport
exports.deleteRapport = async (req, res) => {
    try {
        const rapport = await Rapport.findByPk(req.params.id_rapport);

        if (!rapport) {
            return res.status(404).json({ message: 'Rapport non trouvé' });
        }

        await rapport.destroy();

        res.status(200).json({ message: 'Rapport supprimé avec succès' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Erreur lors de la suppression du rapport', error });
    }
};
