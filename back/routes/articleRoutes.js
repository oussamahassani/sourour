const express = require('express');
const router = express.Router();
const ArticleController = require('../controllers/article.controller');

// Routes CRUD pour les articles
router.post('/', ArticleController.ajouterArticle);         // Ajouter un article
router.get('/', ArticleController.listerArticles);         // Lister tous les articles
router.get('/:id', ArticleController.getArticleById);      // Récupérer un article par ID
router.put('/:id', ArticleController.updateArticle);       // Modifier un article
router.delete('/:id', ArticleController.supprimerArticle); // Supprimer un article

module.exports = router;
