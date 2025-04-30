const Vente = require('../models/Vente');

// Fonction pour créer une vente
exports.createVente = async (req, res) => {
    try {
        const {
            idCL,
            idU,
            idP,
            id_article,
            date_vente,
            type_vente,
            remise,
            prixHTV,
            TVA,
            quantité,
            numVENTE,
            date_livraison,
            statut,
            id_document,
            garantie_mois
        } = req.body;

        // Calcul du prix TTC
        const prixTTC = prixHTV * (1 + TVA / 100);

        // Création de la vente
        const nouvelleVente = new Vente({
            idCL,
            idU,
            idP,
            id_article,
            date_vente,
            type_vente,
            remise,
            validation_admin: false,  // Initialement non validée
            prixHTV,
            TVA,
            prixTTC,
            quantité,
            numVENTE,
            date_livraison,
            statut,
            id_document,
            garantie_mois
        });

        // Sauvegarde de la vente dans la base de données
        await nouvelleVente.save();
        res.status(201).json({ message: 'Vente créée avec succès', nouvelleVente });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de la création de la vente' });
    }
};

// Fonction pour obtenir toutes les ventes
exports.getAllVentes = async (req, res) => {
    try {
        const ventes = await Vente.find()
            .populate('idCL') // Récupérer les informations du client
            .populate('idU')  // Récupérer les informations de l'utilisateur
            .populate('idP')  // Récupérer les informations du produit
            .populate('id_article') // Récupérer les informations de l'article
            .populate('id_document'); // Récupérer le document associé à la vente

        res.status(200).json(ventes);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de la récupération des ventes' });
    }
};

// Fonction pour obtenir une vente par son ID
exports.getVenteById = async (req, res) => {
    try {
        const vente = await Vente.findById(req.params.idV)
            .populate('idCL')
            .populate('idU')
            .populate('idP')
            .populate('id_article')
            .populate('id_document');

        if (!vente) {
            return res.status(404).json({ error: 'Vente non trouvée' });
        }

        res.status(200).json(vente);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de la récupération de la vente' });
    }
};

// Fonction pour mettre à jour une vente (par exemple, pour modifier son statut ou appliquer une remise)
exports.updateVente = async (req, res) => {
    try {
        const vente = await Vente.findById(req.params.idV);
        if (!vente) {
            return res.status(404).json({ error: 'Vente non trouvée' });
        }

        // Mise à jour de la vente avec les données fournies dans le corps de la requête
        const updatedVente = await Vente.findByIdAndUpdate(
            req.params.idV,
            req.body,
            { new: true } // Retourner le document mis à jour
        );

        res.status(200).json({ message: 'Vente mise à jour avec succès', updatedVente });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de la mise à jour de la vente' });
    }
};

// Fonction pour supprimer une vente
exports.deleteVente = async (req, res) => {
    try {
        const vente = await Vente.findByIdAndDelete(req.params.idV);
        if (!vente) {
            return res.status(404).json({ error: 'Vente non trouvée' });
        }

        res.status(200).json({ message: 'Vente supprimée avec succès' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de la suppression de la vente' });
    }
};

// Fonction pour valider une vente par l'administrateur
exports.validateVente = async (req, res) => {
    try {
        const vente = await Vente.findById(req.params.idV);
        if (!vente) {
            return res.status(404).json({ error: 'Vente non trouvée' });
        }

        // Validation de la vente
        vente.validation_admin = true;
        await vente.save();

        res.status(200).json({ message: 'Vente validée avec succès', vente });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de la validation de la vente' });
    }
};
