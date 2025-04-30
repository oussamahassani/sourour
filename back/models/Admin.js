// Admin.js (model)
const mongoose = require('mongoose');
const Admin = {
    // Ajouter un administrateur
    ajouter: (nom, prenom, email, mdp, telephone, callback) => {
        const sql = `INSERT INTO admin (nom, prenom, email, mdp, telephone) VALUES (?, ?, ?, ?, ?)`;
        db.query(sql, [nom, prenom, email, mdp, telephone], callback);
    },

    // Récupérer tous les administrateurs
    lister: (callback) => {
        const sql = `SELECT id, nom, prenom, email, telephone, datec FROM admin`;
        db.query(sql, callback);
    },

    // Récupérer un administrateur par ID
    trouverParId: (id, callback) => {
        const sql = `SELECT id, nom, prenom, email, telephone, datec FROM admin WHERE id = ?`;
        db.query(sql, [id], callback);
    },

    // Mettre à jour un administrateur
    mettreAJour: (id, nom, prenom, email, telephone, callback) => {
        const sql = `UPDATE admin SET nom = ?, prenom = ?, email = ?, telephone = ? WHERE id = ?`;
        db.query(sql, [nom, prenom, email, telephone, id], callback);
    },

    // Supprimer un administrateur
    supprimer: (id, callback) => {
        const sql = `DELETE FROM admin WHERE id = ?`;
        db.query(sql, [id], callback);
    }
};

module.exports = Admin;
