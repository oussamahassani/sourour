const mongoose = require('mongoose');

const accountSchema = new mongoose.Schema({
    name: { type: String, unique: true },
    type: { type: String, required: true }
});

module.exports = mongoose.model('Account', accountSchema);



