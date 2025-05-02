const SaleInvoice = require('../../../models/SaleInvoice');
const Transaction = require('../../../models/Transaction'); // Your Transaction model

const createSinglePaymentSaleInvoice = async (req, res) => {
  const { date, amount, discount, sale_invoice_no } = req.body;

  try {
    const formattedDate = new Date(date).toISOString().split("T")[0];
    const invoiceId = parseInt(sale_invoice_no);

    // Create payment transaction
    const transaction1 = await Transaction.create({
      date: new Date(formattedDate),
      debit_id: 1,
      credit_id: 4,
      amount: parseFloat(amount),
      particulars: `Received payment of Sale Invoice #${invoiceId}`,
      type: "sale",
      related_id: invoiceId,
    });

    let transaction2 = null;

    if (parseFloat(discount) > 0) {
      transaction2 = await Transaction.create({
        date: new Date(formattedDate),
        debit_id: 14,
        credit_id: 4,
        amount: parseFloat(discount),
        particulars: `Discount given for Sale Invoice #${invoiceId}`,
        type: "sale",
        related_id: invoiceId,
      });

      await SaleInvoice.findOneAndUpdate(
        { id: invoiceId },
        { $inc: { profit: -parseFloat(discount) } }
      );
    }

    res.status(200).json({ transaction1, transaction2 });
  } catch (error) {
    console.error("MongoDB Error:", error.message);
    res.status(400).json({ error: error.message });
  }
};

const getAllPaymentSaleInvoice = async (req, res) => {
  const query = req.query.query;

  try {
    if (query === "all") {
      const allPayments = await Transaction.find({ type: "payment_sale_invoice" }).sort({ _id: -1 });
      return res.json(allPayments);
    }

    if (query === "info") {
      const [summary] = await Transaction.aggregate([
        { $match: { type: "payment_sale_invoice" } },
        {
          $group: {
            _id: null,
            count: { $sum: 1 },
            totalAmount: { $sum: "$amount" },
          },
        },
      ]);
      return res.json(summary || { count: 0, totalAmount: 0 });
    }

    // Pagination
    const { skip, limit } = getPagination(req.query);
    const paginatedPayments = await Transaction.find({ type: "payment_sale_invoice" })
      .sort({ _id: -1 })
      .skip(Number(skip))
      .limit(Number(limit));

    res.json(paginatedPayments);
  } catch (error) {
    console.error("MongoDB Fetch Error:", error.message);
    res.status(400).json({ error: error.message });
  }
};

module.exports = {
  createSinglePaymentSaleInvoice,
  getAllPaymentSaleInvoice,

};
