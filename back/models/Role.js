const mongoose = require('mongoose');

const RoleSchema = new mongoose.Schema({
    name: { type: String, unique: true, required: true },
    status: { type: Boolean, default: true },
    rolePermission: [{ type: mongoose.Schema.Types.ObjectId, ref: 'RolePermission' }],
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
  });

// Méthode pour comparer les mots de passe

module.exports = mongoose.model('Role', RoleSchema);