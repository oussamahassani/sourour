const Tableau = require('../models/Tableaux_bord');  // Correct path to the model

// Create a new tableau
exports.createTableau = async (req, res) => {
  try {
    const { titre, id_utilisateur, configuration } = req.body;

    // Create a new Tableau document using the schema
    const newTableau = new Tableau({
      titre,
      id_utilisateur,
      configuration
    });

    // Save the new tableau to the database
    await newTableau.save();
    
    res.status(201).json({
      message: 'Tableau created successfully',
      tableau: newTableau
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: 'Error creating tableau',
      error: error.message
    });
  }
};
