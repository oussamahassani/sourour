const BonCommande = require('../models/bonCommandeVente');
const Article = require('../models/Article');
const Client = require('../models/Client');
const fs = require('fs');
const path = require('path');

// Créer un bon de commande (méthode complète)
exports.createBonCommande = async (req, res) => {
  try {
    const { client, articles, ...bonData } = req.body;

    // Vérifier que le client existe
    const clientExists = await Client.findById(client);
    if (!clientExists) {
      return res.status(404).json({ message: 'Client non trouvé' });
    }

    // Vérifier les articles
    for (const item of articles) {
      if (item.article) {
        const articleExists = await Article.findById(item.article);
        if (!articleExists) {
          return res.status(404).json({ message: `Article ${item.article} non trouvé` });
        }
      }
    }

    const bonCommande = new BonCommande({
      ...bonData,
      client,
      articles,
      methode: 'complete'
    });

    await bonCommande.save();
    res.status(201).json(bonCommande);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Créer un bon de commande rapide (avec image)
exports.createBonCommandeRapide = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Veuillez uploader une image du bon de commande' });
    }

    const { client, reference } = req.body;

    const bonCommande = new BonCommande({
      reference,
      client,
      methode: 'rapide',
      imagePath: req.file.path,
      statut: 'en_attente'
    });

    await bonCommande.save();
    res.status(201).json(bonCommande);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Lister tous les bons de commande
exports.getAllBonCommandes = async (req, res) => {
  try {
    const bons = await BonCommande.find()
      .populate('client', 'nom email telephone')
      .sort({ date: -1 });
    res.json(bons);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtenir un bon de commande par ID
exports.getBonCommandeById = async (req, res) => {
  try {
    const bon = await BonCommande.findById(req.params.id)
      .populate('client')
      .populate('articles.article');

    if (!bon) {
      return res.status(404).json({ message: 'Bon de commande non trouvé' });
    }

    res.json(bon);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Mettre à jour le statut d'un bon de commande
exports.updateStatut = async (req, res) => {
  try {
    const { statut } = req.body;
    const bon = await BonCommande.findByIdAndUpdate(
      req.params.id,
      { statut },
      { new: true }
    );

    if (!bon) {
      return res.status(404).json({ message: 'Bon de commande non trouvé' });
    }

    res.json(bon);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Supprimer un bon de commande
exports.deleteBonCommande = async (req, res) => {
  try {
    const bon = await BonCommande.findByIdAndDelete(req.params.id);

    if (!bon) {
      return res.status(404).json({ message: 'Bon de commande non trouvé' });
    }

    // Supprimer l'image associée si méthode rapide
    if (bon.methode === 'rapide' && bon.imagePath) {
      fs.unlink(bon.imagePath, (err) => {
        if (err) console.error('Erreur suppression image:', err);
      });
    }

    res.json({ message: 'Bon de commande supprimé avec succès' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Générer un PDF pour un bon de commande
exports.generatePdf = async (req, res) => {
  try {
    const bon = await BonCommande.findById(req.params.id)
      .populate('client')
      .populate('articles.article');

    if (!bon) {
      return res.status(404).json({ message: 'Bon de commande non trouvé' });
    }

    // Ici vous utiliseriez une librairie comme pdfkit ou pdfmake pour générer le PDF
    // Pour cet exemple, on retourne simplement les données
    
    res.json({
      message: 'PDF généré avec succès',
      data: bon,
      pdfBuffer: null // Remplacez par le buffer PDF réel en production
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
