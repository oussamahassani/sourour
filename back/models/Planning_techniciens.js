const { Sequelize, DataTypes } = require('sequelize');
const sequelize = new Sequelize('mysql://user:password@localhost:3306/gestion_entreprise');

const PlanningTechniciens = sequelize.define('PlanningTechniciens', {
  idPL: {
    type: DataTypes.BIGINT.UNSIGNED,
    autoIncrement: true,
    primaryKey: true,
  },
  idU: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  idCL: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  date_intervention: {
    type: DataTypes.DATEONLY,
    allowNull: false,
  },
  heure_debut: {
    type: DataTypes.TIME,
    allowNull: true,
  },
  heure_fin: {
    type: DataTypes.TIME,
    allowNull: true,
  },
  description_intervention: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  type_intervention: {
    type: DataTypes.STRING(100),
    allowNull: true,
  },
  statut: {
    type: DataTypes.STRING(50),
    defaultValue: 'En attente',
    allowNull: false,
  },
  priorite: {
    type: DataTypes.ENUM('Basse', 'Normale', 'Haute', 'Urgente'),
    defaultValue: 'Normale',
    allowNull: false,
  },
  adresse_intervention: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  id_equipement: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  recurrente: {
    type: DataTypes.TINYINT(1),
    defaultValue: 0,
    allowNull: false,
  },
  periodicite: {
    type: DataTypes.STRING(50),
    allowNull: true,
  }
}, {
  tableName: 'planning_techniciens',
  timestamps: false,
});

module.exports = PlanningTechniciens;
