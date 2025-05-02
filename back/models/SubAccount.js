const mongoose = require('mongoose');

const subAccountSchema = new mongoose.Schema({
    name: { type: String, unique: true },
    account: { type: mongoose.Schema.Types.ObjectId, ref: 'Account' },
    status: { type: Boolean, default: true }
});

module.exports = mongoose.model('SubAccount', subAccountSchema);
