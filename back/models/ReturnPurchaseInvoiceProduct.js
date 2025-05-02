const mongoose = require('mongoose');

const returnPurchaseInvoiceProductSchema = new mongoose.Schema({
    product: { type: mongoose.Schema.Types.ObjectId, ref: 'Article' },
    invoice: { type: mongoose.Schema.Types.ObjectId, ref: 'ReturnPurchaseInvoice' },
    product_quantity: Number,
    product_purchase_price: Number,
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ReturnPurchaseInvoiceProduct', returnPurchaseInvoiceProductSchema);
