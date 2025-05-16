const Devis = require('../models/Vente');
const Client = require('../models/Client');
const Article = require('../models/Article');
const fs = require('fs');
const path = require('path');

// Créer un devis (méthode complète)
exports.createDevisComplete = async (req, res) => {
  try {
    const { client, articles, ...devisData } = req.body;
    
    // Vérifier client
    const clientExists = await Client.findById(client);
    if (!clientExists) {
      return res.status(404).json({ message: 'Client non trouvé' });
    }

    // Traiter les articles
    const processedArticles = await Promise.all(articles.map(async article => {
      const articleData = await Article.findById(article.nom);
      if (!articleData) {
        throw new Error(`Article ${article.article} non trouvé`);
      }

      const prixHT = article.prixHT || articleData.prix_vente;
      const tva = articleData.tva || 20.0;
      const quantite = article.quantite || 1;
      const montantHT = prixHT * quantite;
      const montantTVA = montantHT * (tva / 100);
      const montantTTC = montantHT + montantTVA;

      return {
        article: article.nom,
        nom: articleData.article,
        description: article.description || articleData.description,
        quantite,
        prixHT,
        tva,
        montantHT,
        montantTVA,
        montantTTC
      };
    }));

    // Calculer les totaux
    const sousTotalHT = processedArticles.reduce((sum, a) => sum + a.montantHT, 0);
    const totalTVA = processedArticles.reduce((sum, a) => sum + a.montantTVA, 0);
    const remise = devisData.remise || 0;
    const totalHT = sousTotalHT - remise;
    const totalTTC = totalHT + totalTVA;
 let adresse = req.body.adresse
    const newDevis = new Devis({
      ...devisData,
      client,
     adresseLivraison:adresse,
      articles: processedArticles,
      sousTotalHT,
      totalTVA,
      totalHT,
      totalTTC,
      methode: 'complete'
    });

    await newDevis.save();
    res.status(201).json(newDevis);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Créer un devis rapide
exports.createDevisRapide = async (req, res) => {
  try {
    const { client, reference } = req.body;
    
    if (!req.file) {
      return res.status(400).json({ message: 'Image du devis requise' });
    }

    const clientExists = await Client.findById(client);
    if (!clientExists) {
      return res.status(404).json({ message: 'Client non trouvé' });
    }

    const newDevis = new Devis({
      client,
      reference,
      methode: 'rapide',
      imageDevis: req.file.path,
      adresseLivraison: 'À déterminer',
      conditionsPaiement: 'À déterminer',
      validite: 30,
      remise: 0,
      sousTotalHT: 0,
      totalTVA: 0,
      totalHT: 0,
      totalTTC: 0
    });

    await newDevis.save();
    res.status(201).json(newDevis);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Get all devis
exports.getAllDevis = async (req, res) => {
  try {
    const { status, method, client, startDate, endDate } = req.query;
    const filter = {};
    
    if (status) filter.statut = status;
    if (method) filter.methode = method;
    if (client) filter.client = client;
    
    if (startDate || endDate) {
      filter.dateCreation = {};
      if (startDate) filter.dateCreation.$gte = new Date(startDate);
      if (endDate) filter.dateCreation.$lte = new Date(endDate);
    }

    const devis = await Devis.find(filter)
      .populate('client', 'nom prenom entreprise')
      .populate('createdBy', 'name')
      .sort({ dateCreation: -1 });

    res.json(devis);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get single devis
exports.getDevisById = async (req, res) => {
  try {
    const devis = await Devis.findById(req.params.id)
      .populate('client')
      .populate('articles.article')
      .populate('createdBy', 'name');

    if (!devis) {
      return res.status(404).json({ message: 'Devis not found' });
    }

    res.json(devis);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Update devis status
exports.updateDevisStatus = async (req, res) => {
  try {
    const { statut } = req.body;
    
    const devis = await Devis.findByIdAndUpdate(
      req.params.id,
      { statut },
      { new: true }
    );

    if (!devis) {
      return res.status(404).json({ message: 'Devis not found' });
    }

    res.json(devis);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Delete devis
exports.deleteDevis = async (req, res) => {
  try {
    const devis = await Devis.findByIdAndDelete(req.params.id);

    if (!devis) {
      return res.status(404).json({ message: 'Devis not found' });
    }

    // Delete associated image if exists
    if (devis.imageDevis && fs.existsSync(devis.imageDevis)) {
      fs.unlinkSync(devis.imageDevis);
    }

    res.json({ message: 'Devis deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Generate PDF for devis
exports.generateDevisPDF = async (req, res) => {
  try {
    const devis = await Devis.findById(req.params.id)
      .populate('client')
      .populate('articles.article');

    if (!devis) {
      return res.status(404).json({ message: 'Devis not found' });
    }

    // Here you would implement PDF generation logic
    // For example using pdfkit or another library
    // This is a placeholder implementation
    
    const pdfData = {
      reference: devis.reference,
      date: devis.dateCreation.toLocaleDateString(),
      client: devis.client,
      articles: devis.articles,
      totals: {
        sousTotalHT: devis.sousTotalHT,
        remise: devis.remise,
        totalHT: devis.totalHT,
        totalTVA: devis.totalTVA,
        totalTTC: devis.totalTTC
      }
    };

    // In a real implementation, you would generate the PDF file here
    // and send it as a response
    
    res.json({
      message: 'PDF generation would happen here',
      data: pdfData
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
