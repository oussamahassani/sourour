const { body } = require('express-validator');

exports.validateSignup = [
  body('nom').notEmpty().withMessage('Le nom est requis.'),
  body('prenom').notEmpty().withMessage('Le prénom est requis.'),
  body('telephone').notEmpty().withMessage('Le téléphone est requis.'),
  body('email').isEmail().withMessage('Un email valide est requis.'),
  body('motDePasse').isLength({ min: 6 }).withMessage('Le mot de passe doit contenir au moins 6 caractères.'),
  body('role').notEmpty().withMessage('Le rôle est requis.'),
];

exports.validateLogin = [
  body('email').isEmail().withMessage('Un email valide est requis.'),
  body('motDePasse').notEmpty().withMessage('Le mot de passe est requis.'),
];