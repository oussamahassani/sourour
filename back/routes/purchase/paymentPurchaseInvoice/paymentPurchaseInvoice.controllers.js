const getPagination = require("../../../utils/pagination");
const Transaction = require('../../../models/Transaction'); // adjust path as needed


const createPaymentPurchaseInvoice = async (req, res) => {
  try {
    const date = new Date(req.body.date).toISOString().split('T')[0];

    // First transaction: main payment
    const transaction1 = await Transaction.create({
      date: new Date(date),
      debit: req.body.debit_id || 5, // You can dynamically assign if needed
      credit: req.body.credit_id || 1,
      amount: parseFloat(req.body.amount),
      particulars: `Due pay of Purchase Invoice #${req.body.purchase_invoice_no}`,
      type: 'purchase',
      related_id: parseInt(req.body.purchase_invoice_no),
    });

    // Optional second transaction: discount
    let transaction2 = null;
    if (parseFloat(req.body.discount) > 0) {
      transaction2 = await Transaction.create({
        date: new Date(date),
        debit: req.body.debit_id || 5,
        credit: 13,
        amount: parseFloat(req.body.discount),
        particulars: `Discount earned of Purchase Invoice #${req.body.purchase_invoice_no}`,
        type: 'purchase',
        related_id: parseInt(req.body.purchase_invoice_no),
      });
    }

    res.status(200).json({ transaction1, transaction2 });
  } catch (error) {
    console.error(error.message);
    res.status(400).json({ error: error.message });
  }
};


const getAllPaymentPurchaseInvoice = async (req, res) => {
  try {
    if (req.query.query === 'all') {
      const allTransactions = await Transaction.find({ type: 'purchase' }).sort({ _id: -1 });
      return res.json(allTransactions);
    }

    if (req.query.query === 'info') {
      const allTransactions = await Transaction.aggregate([
        { $match: { type: 'purchase' } },
        {
          $group: {
            _id: null,
            totalAmount: { $sum: '$amount' },
            count: { $sum: 1 },
          },
        },
      ]);

      const result = allTransactions[0] || { totalAmount: 0, count: 0 };
      return res.json({ _sum: { amount: result.totalAmount }, _count: { id: result.count } });
    }

    const { skip = 0, limit = 10 } = req.query;
    const paginatedTransactions = await Transaction.find({ type: 'purchase' })
      .sort({ _id: -1 })
      .skip(Number(skip))
      .limit(Number(limit));

    res.json(paginatedTransactions);
  } catch (error) {
    console.error(error.message);
    res.status(400).json({ error: error.message });
  }
};


module.exports = {
  createPaymentPurchaseInvoice,
  getAllPaymentPurchaseInvoice,

};
