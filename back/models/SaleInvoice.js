const mongoose = require('mongoose');
const SaleInvoiceProductSchema = new mongoose.Schema({
    product: { type: mongoose.Schema.Types.ObjectId, ref: 'Article' },
    product_quantity: Number,
    product_sale_price: Number,
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});
const saleInvoiceSchema = new mongoose.Schema({
    date: { type: Date, required: true },
    total_amount: Number,
    discount: Number,
    paid_amount: Number,
    due_amount: Number,
    profit: Number,
    customer: { type: mongoose.Schema.Types.ObjectId, ref: 'Client' },
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    note: String,
    saleInvoiceProduct: [SaleInvoiceProductSchema],
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('SaleInvoice', saleInvoiceSchema);
