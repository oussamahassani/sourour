const express = require('express');
const router = express.Router();
const { ajouterAudit, listeAudits } = require('../controllers/journal_audit.controller');

// Route POST pour ajouter un audit
router.post('/ajouter', ajouterAudit);

// Route GET pour lister tous les audits
router.get('/', listeAudits);

module.exports = router;
