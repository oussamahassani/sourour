const mongoose = require('mongoose');

const RolePermissionSchema = new mongoose.Schema({
  role: { type: mongoose.Schema.Types.ObjectId, ref: "Role", required: true },
  permission: { type: mongoose.Schema.Types.ObjectId, ref: "Permission", required: true },
});

// Méthode pour comparer les mots de passe

module.exports = mongoose.model('RolePermission', RolePermissionSchema);