const AppSetting = require('../../models/AppSetting');

// Update settings (assumes single settings document with a fixed _id or just one document in collection)
const updateSetting = async (req, res) => {
  try {
    // Assuming there's only one settings document (like in your Prisma `id: 1`)
    const updatedSetting = await AppSetting.findOneAndUpdate(
      {}, // match the only document
      { ...req.body },
      { new: true, upsert: true } // creates if doesn't exist
    );
    res.status(201).json(updatedSetting);
  } catch (error) {
    console.error(error.message);
    res.status(400).json({ error: error.message });
  }
};

// Get settings
const getSetting = async (req, res) => {
  try {
    const setting = await AppSetting.findOne(); // get the only document
    res.status(200).json(setting);
  } catch (error) {
    console.error(error.message);
    res.status(400).json({ error: error.message });
  }
};


module.exports = {
  updateSetting,
  getSetting,
};
