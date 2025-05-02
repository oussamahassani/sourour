const mongoose = require('mongoose');

const returnSaleInvoiceSchema = new mongoose.Schema({
    date: { type: Date, required: true },
    total_amount: Number,
    note: String,
    saleInvoice: { type: mongoose.Schema.Types.ObjectId, ref: 'SaleInvoice' },
    status: { type: Boolean, default: true },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ReturnSaleInvoice', returnSaleInvoiceSchema);
