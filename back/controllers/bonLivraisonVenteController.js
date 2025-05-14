const BonLivraison = require('../models/BonLivraison');
const Article = require('../models/Article');

exports.create = async (req, res) => {
  try {
    const { client, articles } = req.body;
    
    // Vérification des articles
    for (const item of articles) {
      const article = await Article.findById(item.article);
      if (!article) {
        return res.status(400).json({ error: `Article ${item.article} introuvable` });
      }
      item.prixHT = article.prixHT; // Récupération du prix
    }

    const bonLivraison = new BonLivraison(req.body);
    await bonLivraison.save();
    
    res.status(201).json(bonLivraison);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getAll = async (req, res) => {
  try {
    const bons = await BonLivraison.find()
      .populate('client', 'nom')
      .populate('articles.article', 'designation');
    res.json(bons);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getById = async (req, res) => {
  try {
    const bon = await BonLivraison.findById(req.params.id)
      .populate('client')
      .populate('articles.article');
    
    if (!bon) return res.status(404).json({ error: 'Bon non trouvé' });
    res.json(bon);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.update = async (req, res) => {
  try {
    const bon = await BonLivraison.findByIdAndUpdate(
      req.params.id, 
      req.body, 
      { new: true }
    );
    
    if (!bon) return res.status(404).json({ error: 'Bon non trouvé' });
    res.json(bon);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.delete = async (req, res) => {
  try {
    const bon = await BonLivraison.findByIdAndDelete(req.params.id);
    if (!bon) return res.status(404).json({ error: 'Bon non trouvé' });
    res.json({ message: 'Bon supprimé' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}
