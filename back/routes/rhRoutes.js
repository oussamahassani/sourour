const express = require('express');
const router = express.Router();

// Import the controller
const EmployeeController = require('../controllers/rh.controller');  // Correct path to your controller file

// Define routes
router.post('/employees', EmployeeController.createEmployee);
router.get('/employees', EmployeeController.getAllEmployees);
router.get('/employees/:id', EmployeeController.getEmployeeById);
router.put('/employees/:id', EmployeeController.updateEmployee);
router.delete('/employees/:id', EmployeeController.deleteEmployee);

module.exports = router;
