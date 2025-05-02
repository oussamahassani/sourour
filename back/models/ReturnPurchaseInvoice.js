const mongoose = require('mongoose');

const returnPurchaseInvoiceSchema = new mongoose.Schema({
    date: { type: Date, required: true },
    total_amount: Number,
    note: String,
    purchaseInvoice: { type: mongoose.Schema.Types.ObjectId, ref: 'PurchaseInvoice' },
    status: { type: Boolean, default: true },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ReturnPurchaseInvoice', returnPurchaseInvoiceSchema);
