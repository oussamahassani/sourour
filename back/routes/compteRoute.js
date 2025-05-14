const express = require('express');
const {
  getComptes,
  getCompte,
  createCompte,
  updateCompte,
  deleteCompte
} = require('../controllers/compteController');

const router = express.Router();

router.route('/')
  .get(getComptes)
  .post(createCompte);

router.route('/:id')
  .get(getCompte)
  .put(updateCompte)
  .delete(deleteCompte);

module.exports = router;
