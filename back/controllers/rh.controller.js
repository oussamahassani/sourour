const Employee = require('../models/RH');
// Create a new employee
exports.createEmployee = async (req, res) => {
    try {
        const employee = new Employee(req.body);  // Create an instance using the request body
        await employee.save();  // Save the employee to the database
        res.status(201).json(employee);  // Respond with the newly created employee
    } catch (error) {
        res.status(400).json({ message: error.message });  // Handle errors
    }
};

// Get all employees
exports.getAllEmployees = async (req, res) => {
    try {
        const employees = await Employee.find();  // Fetch all employees from the database
        res.status(200).json(employees);  // Respond with the list of employees
    } catch (error) {
        res.status(400).json({ message: error.message });  // Handle errors
    }
};

// Get a single employee by ID
exports.getEmployeeById = async (req, res) => {
    try {
        const employee = await Employee.findById(req.params.id);  // Find employee by ID
        if (!employee) {
            return res.status(404).json({ message: 'Employee not found' });
        }
        res.status(200).json(employee);  // Respond with the found employee
    } catch (error) {
        res.status(400).json({ message: error.message });  // Handle errors
    }
};

// Update an existing employee
exports.updateEmployee = async (req, res) => {
    try {
        const employee = await Employee.findByIdAndUpdate(
            req.params.id,  // Find employee by ID
            req.body,  // Update with the request body
            { new: true }  // Return the updated employee
        );
        if (!employee) {
            return res.status(404).json({ message: 'Employee not found' });
        }
        res.status(200).json(employee);  // Respond with the updated employee
    } catch (error) {
        res.status(400).json({ message: error.message });  // Handle errors
    }
};

// Delete an employee
exports.deleteEmployee = async (req, res) => {
    try {
        const employee = await Employee.findByIdAndDelete(req.params.id);  // Delete employee by ID
        if (!employee) {
            return res.status(404).json({ message: 'Employee not found' });
        }
        res.status(200).json({ message: 'Employee deleted successfully' });  // Success message
    } catch (error) {
        res.status(400).json({ message: error.message });  // Handle errors
    }
};
