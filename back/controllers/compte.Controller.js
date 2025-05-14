const FinanceRecord = require('../models/FinanceRecord');

// Créer une nouvelle transaction
exports.createRecord = async (req, res) => {
  try {
    const newRecord = new FinanceRecord(req.body);
    const savedRecord = await newRecord.save();
    res.status(201).json(savedRecord);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Récupérer toutes les transactions avec filtres
exports.getAllRecords = async (req, res) => {
  try {
    const { type, startDate, endDate, search, category } = req.query;
    
    let query = {};
    
    // Filtre par type
    if (type && type !== 'Tous') {
      query.type = type;
    }
    
    // Filtre par date
    if (startDate || endDate) {
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate);
      if (endDate) query.date.$lte = new Date(endDate);
    }
    
    // Filtre par catégorie
    if (category) {
      query.category = category;
    }
    
    // Recherche texte
    if (search) {
      query.$or = [
        { description: { $regex: search, $options: 'i' } },
        { reference: { $regex: search, $options: 'i' } },
        { category: { $regex: search, $options: 'i' } }
      ];
    }
    
    const records = await FinanceRecord.find(query).sort({ date: -1 });
    res.json(records);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Récupérer une transaction par ID
exports.getRecordById = async (req, res) => {
  try {
    const record = await FinanceRecord.findById(req.params.id);
    if (!record) {
      return res.status(404).json({ message: 'Transaction non trouvée' });
    }
    res.json(record);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Mettre à jour une transaction
exports.updateRecord = async (req, res) => {
  try {
    const updatedRecord = await FinanceRecord.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    if (!updatedRecord) {
      return res.status(404).json({ message: 'Transaction non trouvée' });
    }
    res.json(updatedRecord);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Supprimer une transaction
exports.deleteRecord = async (req, res) => {
  try {
    const deletedRecord = await FinanceRecord.findByIdAndDelete(req.params.id);
    if (!deletedRecord) {
      return res.status(404).json({ message: 'Transaction non trouvée' });
    }
    res.json({ message: 'Transaction supprimée avec succès' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Statistiques financières
exports.getFinancialStats = async (req, res) => {
  try {
    const records = await FinanceRecord.find();
    
    const totalIncome = records
      .filter(r => r.type === 'Vente')
      .reduce((sum, r) => sum + r.amount, 0);
    
    const totalExpense = records
      .filter(r => ['Achat', 'Frais'].includes(r.type))
      .reduce((sum, r) => sum + r.amount, 0);
    
    const totalTVA = records
      .reduce((sum, r) => sum + r.tvaNet, 0);
    
    const netBalance = totalIncome - totalExpense;
    
    res.json({
      totalIncome,
      totalExpense,
      totalTVA,
      netBalance
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
