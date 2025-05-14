const Intervention = require('../models/Intervention');
const Client = require('../models/Client');

// @desc    Get all interventions
// @route   GET /api/interventions
// @access  Public
exports.getInterventions = async (req, res) => {
  try {
    const { isCompleted } = req.query;
    let query = {};
    
    if (isCompleted) {
      query.isCompleted = isCompleted === 'true';
    }
    
    const interventions = await Intervention.find(query)
      .sort({ date: 1, 'time.hour': 1, 'time.minute': 1 })
      .populate('clientId', 'name phone email');
      
    res.json(interventions);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @desc    Get single intervention
// @route   GET /api/interventions/:id
// @access  Public
exports.getIntervention = async (req, res) => {
  try {
    const intervention = await Intervention.findById(req.params.id)
      .populate('clientId', 'name phone email');
      
    if (!intervention) {
      return res.status(404).json({ msg: 'Intervention not found' });
    }
    
    res.json(intervention);
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Intervention not found' });
    }
    res.status(500).send('Server Error');
  }
};

// @desc    Create an intervention
// @route   POST /api/interventions
// @access  Public
exports.createIntervention = async (req, res) => {
  const {
    clientId,
    referenceNumber,
    date,
    time,
    interventionType,
    estimatedDuration,
    technicianName,
    technicianAddress,
    notes
  } = req.body;

  try {
    // Get client info
    const client = await Client.findById(clientId);
    if (!client) {
      return res.status(404).json({ msg: 'Client not found' });
    }

    const newIntervention = new Intervention({
      clientId,
      clientName: client.name,
      address: client.address,
      phone: client.phone,
      email: client.email,
      referenceNumber,
      date,
      time,
      interventionType,
      estimatedDuration,
      technicianName,
      technicianAddress,
      notes,
      isCompleted: false
    });

    const intervention = await newIntervention.save();
    res.json(intervention);
  } catch (err) {
    console.error(err.message);
    if (err.code === 11000) {
      return res.status(400).json({ msg: 'Reference number must be unique' });
    }
    res.status(500).send('Server Error');
  }
};

// @desc    Update intervention
// @route   PUT /api/interventions/:id
// @access  Public
exports.updateIntervention = async (req, res) => {
  const {
    referenceNumber,
    date,
    time,
    interventionType,
    estimatedDuration,
    actualDuration,
    technicianName,
    technicianAddress,
    isCompleted,
    notes
  } = req.body;

  try {
    let intervention = await Intervention.findById(req.params.id);

    if (!intervention) {
      return res.status(404).json({ msg: 'Intervention not found' });
    }

    const interventionFields = {
      referenceNumber,
      date,
      time,
      interventionType,
      estimatedDuration,
      actualDuration,
      technicianName,
      technicianAddress,
      isCompleted,
      notes
    };

    intervention = await Intervention.findByIdAndUpdate(
      req.params.id,
      { $set: interventionFields },
      { new: true }
    );

    res.json(intervention);
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Intervention not found' });
    }
    res.status(500).send('Server Error');
  }
};

// @desc    Delete intervention
// @route   DELETE /api/interventions/:id
// @access  Public
exports.deleteIntervention = async (req, res) => {
  try {
    const intervention = await Intervention.findById(req.params.id);

    if (!intervention) {
      return res.status(404).json({ msg: 'Intervention not found' });
    }

    await intervention.remove();
    res.json({ msg: 'Intervention removed' });
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Intervention not found' });
    }
    res.status(500).send('Server Error');
  }
};

// @desc    Mark intervention as completed
// @route   PUT /api/interventions/:id/complete
// @access  Public
exports.markAsCompleted = async (req, res) => {
  try {
    let intervention = await Intervention.findById(req.params.id);

    if (!intervention) {
      return res.status(404).json({ msg: 'Intervention not found' });
    }

    intervention = await Intervention.findByIdAndUpdate(
      req.params.id,
      { $set: { isCompleted: true } },
      { new: true }
    );

    res.json(intervention);
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Intervention not found' });
    }
    res.status(500).send('Server Error');
  }
};
