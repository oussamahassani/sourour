const mongoose = require('mongoose');

const returnSaleInvoiceProductSchema = new mongoose.Schema({
    product: { type: mongoose.Schema.Types.ObjectId, ref: 'Article' },
    invoice: { type: mongoose.Schema.Types.ObjectId, ref: 'ReturnSaleInvoice' },
    product_quantity: Number,
    product_sale_price: Number,
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ReturnSaleInvoiceProduct', returnSaleInvoiceProductSchema);
