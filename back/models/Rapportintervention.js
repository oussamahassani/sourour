const mongoose = require('mongoose');

const Rapport_interventionSchema = new mongoose.Schema({
  clientName: {
    type: String,
    required: [true, 'Client name is required']
  },
  address: {
    type: String,
    required: [true, 'Address is required']
  },
  technicianName: {
    type: String,
    required: [true, 'Technician name is required']
  },
  date: {
    type: Date,
    required: [true, 'Date is required']
  },
  time: {
    type: String,
    required: [true, 'Time is required']
  },
  interventionType: {
    type: String,
    required: [true, 'Intervention type is required']
  },
  description: {
    type: String,
    required: [true, 'Description is required']
  },
  actionsTaken: {
    type: String,
    required: [true, 'Actions taken is required']
  },
  materialsUsed: {
    type: String,
    required: [true, 'Materials used is required']
  },
  actualDuration: {
    type: String,
    required: [true, 'Duration is required']
  },
  observations: {
    type: String,
    required: false
  },
  recommendations: {
    type: String,
    required: false
  },
  clientSignature: {
    type: String,
    required: false
  },
  clientSatisfied: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  },
  reference: {
    type: String,
    unique: true
  }
});

// Generate reference before saving
Rapport_interventionSchema.pre('save', function(next) {
  const now = new Date();
  if (!this.reference) {
    this.reference = `INT-${now.getFullYear()}-${(now.getMonth()+1).toString().padStart(2, '0')}${now.getDate().toString().padStart(2, '0')}-${this.clientName.substring(0, 3).toUpperCase()}-${Math.floor(1000 + Math.random() * 9000)}`;
  }
  next();
});

module.exports = mongoose.model('Rapport_intervention', Rapport_interventionSchema);
