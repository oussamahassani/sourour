const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
    date: { type: Date, required: true },
    debit: String,
    credit: String,
    particulars: String,
    amount: Number,
    type: String,
    related_id: String,
    status: { type: Boolean, default: true },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Transaction', transactionSchema);
