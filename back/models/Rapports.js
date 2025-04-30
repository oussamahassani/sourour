const { Sequelize, DataTypes } = require('sequelize'); // Import both Sequelize and DataTypes
const sequelize = require('../config/db');  // Ensure this path is correct

const Rapport = sequelize.define('Rapport', {
  id_rapport: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  titre: {
    type: DataTypes.STRING,
    allowNull: false
  },
  type_rapport: {
    type: DataTypes.ENUM('Vente', 'Achat', 'Stock', 'Finance', 'Performance', 'Client'),
    allowNull: false
  },
  periode_debut: {
    type: DataTypes.DATEONLY,
    allowNull: true
  },
  periode_fin: {
    type: DataTypes.DATEONLY,
    allowNull: true
  },
  contenu: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  chemin_fichier: {
    type: DataTypes.STRING,
    allowNull: true
  },
  date_generation: {
    type: DataTypes.DATE, // Use DataTypes.DATE for date fields
    defaultValue: Sequelize.fn('NOW') // Set the default to the current timestamp
  },
  id_utilisateur: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  parametres: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  planification: {
    type: DataTypes.STRING,
    allowNull: true
  }
}, {
  tableName: 'rapports',
  timestamps: false  // Disable automatic `createdAt` and `updatedAt` columns
});

module.exports = Rapport;
