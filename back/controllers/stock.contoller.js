const Stock = require('../models/Stock');

// Fonction pour créer un stock
exports.createStock = async (req, res) => {
    try {
        const { id_produit, quantite_disponible, seuil_reapprovisionnement, statut_stock } = req.body;

        // Création d'un nouvel objet Stock
        const newStock = new Stock({
            id_produit,
            quantite_disponible,
            seuil_reapprovisionnement,
            statut_stock
        });

        // Enregistrement dans la base de données
        await newStock.save();

        res.status(201).json({ message: 'Stock créé avec succès', newStock });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de la création du stock' });
    }
};

// Fonction pour obtenir la liste de tous les stocks
exports.getAllStocks = async (req, res) => {
    try {
        const stocks = await Stock.find().populate('id_produit');
        res.status(200).json(stocks);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de la récupération des stocks' });
    }
};

// Fonction pour obtenir un stock par son ID
exports.getStockById = async (req, res) => {
    try {
        const stock = await Stock.findById(req.params.id_stock).populate('id_produit');
        if (!stock) {
            return res.status(404).json({ error: 'Stock non trouvé' });
        }
        res.status(200).json(stock);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de la récupération du stock' });
    }
};

// Fonction pour mettre à jour un stock
exports.updateStock = async (req, res) => {
    try {
        const updatedStock = await Stock.findByIdAndUpdate(
            req.params.id_stock,
            req.body,
            { new: true } // Retourner le document mis à jour
        );
        if (!updatedStock) {
            return res.status(404).json({ error: 'Stock non trouvé' });
        }
        res.status(200).json({ message: 'Stock mis à jour avec succès', updatedStock });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de la mise à jour du stock' });
    }
};

// Fonction pour supprimer un stock
exports.deleteStock = async (req, res) => {
    try {
        const deletedStock = await Stock.findByIdAndDelete(req.params.id_stock);
        if (!deletedStock) {
            return res.status(404).json({ error: 'Stock non trouvé' });
        }
        res.status(200).json({ message: 'Stock supprimé avec succès' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de la suppression du stock' });
    }
};

// Fonction pour gérer l'entrée de stock (mise à jour de la quantité disponible)
exports.addStockEntry = async (req, res) => {
    try {
        const { id_stock, quantite_ajoutee } = req.body;

        // Trouver le stock à mettre à jour
        const stock = await Stock.findById(id_stock);
        if (!stock) {
            return res.status(404).json({ error: 'Stock non trouvé' });
        }

        // Mise à jour de la quantité disponible
        stock.quantite_disponible += quantite_ajoutee;
        stock.date_derniere_entree = Date.now();

        // Enregistrement de la mise à jour
        await stock.save();

        res.status(200).json({ message: 'Entrée de stock effectuée avec succès', stock });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de l\'ajout de l\'entrée de stock' });
    }
};

// Fonction pour gérer la sortie de stock (mise à jour de la quantité disponible)
exports.addStockExit = async (req, res) => {
    try {
        const { id_stock, quantite_sortie } = req.body;

        // Trouver le stock à mettre à jour
        const stock = await Stock.findById(id_stock);
        if (!stock) {
            return res.status(404).json({ error: 'Stock non trouvé' });
        }

        // Vérifier si la quantité disponible est suffisante
        if (stock.quantite_disponible < quantite_sortie) {
            return res.status(400).json({ error: 'Quantité insuffisante en stock' });
        }

        // Mise à jour de la quantité disponible
        stock.quantite_disponible -= quantite_sortie;
        stock.date_derniere_sortie = Date.now();

        // Enregistrement de la mise à jour
        await stock.save();

        res.status(200).json({ message: 'Sortie de stock effectuée avec succès', stock });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de la sortie de stock' });
    }
};

// Fonction pour vérifier et réapprovisionner le stock si nécessaire
exports.checkReplenishment = async (req, res) => {
    try {
        const stocks = await Stock.find({ quantite_disponible: { $lt: 'seuil_reapprovisionnement' } });
        res.status(200).json(stocks);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erreur lors de la vérification du réapprovisionnement' });
    }
};

