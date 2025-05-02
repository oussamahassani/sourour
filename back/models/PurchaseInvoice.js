const mongoose = require('mongoose');

const purchaseInvoiceSchema = new mongoose.Schema({
    date: { type: Date, required: true },
    total_amount: Number,
    discount: Number,
    paid_amount: Number,
    due_amount: Number,
    supplier: { type: mongoose.Schema.Types.ObjectId, ref: 'Fournisseur' },
    note: String,
    supplier_memo_no: String,
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('PurchaseInvoice', purchaseInvoiceSchema);
