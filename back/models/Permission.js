const mongoose = require('mongoose');

const PermissionSchema = new mongoose.Schema({
  name: String,
  // autres champs possibles
});


// Méthode pour comparer les mots de passe

module.exports = mongoose.model('Permission', PermissionSchema);