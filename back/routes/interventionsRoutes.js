const express = require('express');
const router = express.Router();
const {
  getInterventions,
  getIntervention,
  createIntervention,
  updateIntervention,
  deleteIntervention,
  markAsCompleted
} = require('../controllers/interventionController');

router.route('/')
  .get(getInterventions)
  .post(createIntervention);

router.route('/:id')
  .get(getIntervention)
  .put(updateIntervention)
  .delete(deleteIntervention);

router.put('/:id/complete', markAsCompleted);

module.exports = router;
