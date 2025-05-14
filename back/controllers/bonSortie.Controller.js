const BonSortie = require('../models/BonSortie');
const Article = require('../models/Article');
const Client = require('../models/Client');

// Create a new Bon de Sortie (sans token)
exports.createBonSortie = async (req, res) => {
  try {
    const {
      responsable,
      service,
      description,
      typeMateriel,
      dateSortie,
      client,
      items
    } = req.body;

    // Validation basique des données requises
    if (!responsable || !service || !description || !typeMateriel || !client || !items || items.length === 0) {
      return res.status(400).json({ message: 'Tous les champs obligatoires doivent être remplis' });
    }

    // Validate items stock
    for (const item of items) {
      const article = await Article.findById(item.article);
      if (!article) {
        return res.status(400).json({ message: `Article ${item.article} non trouvé` });
      }
      if (article.stock < item.quantite) {
        return res.status(400).json({ 
          message: `Stock insuffisant pour l'article ${article.nomArticle}` 
        });
      }
    }

    const bonSortie = new BonSortie({
      responsable,
      service,
      description,
      typeMateriel,
      dateSortie: dateSortie || new Date(),
      client,
      items
      // Suppression de createdBy qui nécessitait un token
    });

    await bonSortie.save();
    
    res.status(201).json(bonSortie);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get all Bon de Sortie (sans token)
exports.getAllBonSortie = async (req, res) => {
  try {
    const { startDate, endDate, statut } = req.query;
    let query = {};
    
    if (startDate && endDate) {
      query.dateSortie = {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      };
    }
    
    if (statut) {
      query.statut = statut;
    }
    
    const bonSorties = await BonSortie.find(query)
      .populate('client', 'nom prenom entreprise')
      .populate('items.article', 'nomArticle reference')
      .sort({ dateSortie: -1 });
      
    res.json(bonSorties);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get Bon de Sortie by ID (sans token)
exports.getBonSortieById = async (req, res) => {
  try {
    const bonSortie = await BonSortie.findById(req.params.id)
      .populate('client')
      .populate('items.article');
      
    if (!bonSortie) {
      return res.status(404).json({ message: 'Bon de sortie non trouvé' });
    }
    
    res.json(bonSortie);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Update Bon de Sortie (sans token)
exports.updateBonSortie = async (req, res) => {
  try {
    const { id } = req.params;
    const bonSortie = await BonSortie.findById(id);
    
    if (!bonSortie) {
      return res.status(404).json({ message: 'Bon de sortie non trouvé' });
    }
    
    if (bonSortie.statut === 'validé') {
      return res.status(400).json({ message: 'Bon de sortie déjà validé, modification impossible' });
    }
    
    // Validate items stock if changing items
    if (req.body.items) {
      for (const item of req.body.items) {
        const article = await Article.findById(item.article);
        if (!article) {
          return res.status(400).json({ message: `Article ${item.article} non trouvé` });
        }
        
        // Check if the item is being modified
        const existingItem = bonSortie.items.find(i => i.article.equals(item.article));
        const stockChange = existingItem ? 
          item.quantite - existingItem.quantite : 
          item.quantite;
          
        if (article.stock < stockChange) {
          return res.status(400).json({ 
            message: `Stock insuffisant pour l'article ${article.nomArticle}` 
          });
        }
      }
    }
    
    Object.assign(bonSortie, req.body);
    await bonSortie.save();
    
    res.json(bonSortie);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Validate Bon de Sortie (sans token)
exports.validateBonSortie = async (req, res) => {
  try {
    const bonSortie = await BonSortie.findById(req.params.id);
    
    if (!bonSortie) {
      return res.status(404).json({ message: 'Bon de sortie non trouvé' });
    }
    
    if (bonSortie.statut === 'validé') {
      return res.status(400).json({ message: 'Bon de sortie déjà validé' });
    }
    
    // Check stock again before validation
    for (const item of bonSortie.items) {
      const article = await Article.findById(item.article);
      if (article.stock < item.quantite) {
        return res.status(400).json({ 
          message: `Stock insuffisant pour l'article ${article.nomArticle}` 
        });
      }
    }
    
    bonSortie.statut = 'validé';
    await bonSortie.save();
    
    res.json(bonSortie);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Cancel Bon de Sortie (sans token)
exports.cancelBonSortie = async (req, res) => {
  try {
    const bonSortie = await BonSortie.findById(req.params.id);
    
    if (!bonSortie) {
      return res.status(404).json({ message: 'Bon de sortie non trouvé' });
    }
    
    if (bonSortie.statut === 'annulé') {
      return res.status(400).json({ message: 'Bon de sortie déjà annulé' });
    }
    
    // If already validated, return stock
    if (bonSortie.statut === 'validé') {
      for (const item of bonSortie.items) {
        await Article.findByIdAndUpdate(
          item.article,
          { $inc: { stock: item.quantite } }
        );
      }
    }
    
    bonSortie.statut = 'annulé';
    await bonSortie.save();
    
    res.json(bonSortie);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Generate PDF for Bon de Sortie (sans token)
exports.generatePdf = async (req, res) => {
  try {
    const bonSortie = await BonSortie.findById(req.params.id)
      .populate('client')
      .populate('items.article');
      
    if (!bonSortie) {
      return res.status(404).json({ message: 'Bon de sortie non trouvé' });
    }
    
    // Ici vous généreriez normalement le PDF avec une bibliothèque comme pdfkit
    // Pour l'exemple, nous retournons simplement les données qui seraient utilisées
    res.json({
      success: true,
      data: bonSortie
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
