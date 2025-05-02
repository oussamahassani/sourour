const SaleInvoice = require('../../../models/SaleInvoice');  // Your SaleInvoice model
const Product = require('../../../models/Article');          // Your Product model
const Transaction = require('../../../models/Transaction'); // Your Transaction model
const Customer = require('../../../models/Client');       //
const getPagination = require("../../../utils/pagination")
const createSingleSaleInvoice = async (req, res) => {
  try {
    // Calculate total sale price
    let totalSalePrice = 0;
    req.body.saleInvoiceProduct.forEach((item) => {
      totalSalePrice += parseFloat(item.product_sale_price) * parseFloat(item.product_quantity);
    });

    // Fetch all product details asynchronously
    const allProduct = await Product.find({
      '_id': { $in: req.body.saleInvoiceProduct.map(item => item.product_id) }
    });

    // Calculate total purchase price
    let totalPurchasePrice = 0;
    req.body.saleInvoiceProduct.forEach((item, index) => {
      totalPurchasePrice += allProduct[index].prix_vente * item.product_quantity;
    });

    // Convert date to ISO format
    const date = new Date(req.body.date).toISOString().split('T')[0];
    console.log(totalSalePrice)
    console.log(totalPurchasePrice)
    console.log(totalSalePrice - parseFloat(req.body.discount) - totalPurchasePrice)
    // Create sale invoice
    const createdInvoice = new SaleInvoice({
      date: new Date(date),
      total_amount: totalSalePrice,
      discount: parseFloat(req.body.discount),
      paid_amount: parseFloat(req.body.paid_amount),
      profit: totalSalePrice - parseFloat(req.body.discount) - totalPurchasePrice,
      due_amount: totalSalePrice - parseFloat(req.body.discount) - parseFloat(req.body.paid_amount),
      customer: req.body.customer_id,
      user: req.body.user_id,
      note: req.body.note,
      saleInvoiceProduct: req.body.saleInvoiceProduct.map((product) => ({
        product: product.product_id,
        product_quantity: product.product_quantity,
        product_sale_price: product.product_sale_price,
      })),
    });

    await createdInvoice.save();

    // Create journal entries for transactions
    if (req.body.paid_amount > 0) {
      await new Transaction({
        date: new Date(date),
        debit_id: 1,
        credit_id: 8,
        amount: req.body.paid_amount,
        particulars: `Cash receive on Sale Invoice #${createdInvoice._id}`,
        type: 'sale',
        related_id: createdInvoice._id,
      }).save();
    }

    const dueAmount = totalSalePrice - parseFloat(req.body.discount) - parseFloat(req.body.paid_amount);
    if (dueAmount > 0) {
      await new Transaction({
        date: new Date(date),
        debit_id: 4,
        credit_id: 8,
        amount: dueAmount,
        particulars: `Due on Sale Invoice #${createdInvoice._id}`,
        type: 'sale',
        related_id: createdInvoice._id,
      }).save();
    }

    // Cost of sales
    await new Transaction({
      date: new Date(date),
      debit_id: 9,
      credit_id: 3,
      amount: totalPurchasePrice,
      particulars: `Cost of sales on Sale Invoice #${createdInvoice._id}`,
      type: 'sale',
      related_id: createdInvoice._id,
    }).save();

    // Update product quantities in the inventory
    for (const item of req.body.saleInvoiceProduct) {
      await Product.updateOne(
        { _id: item.product_id },
        { $inc: { quantity: -item.product_quantity } }
      );
    }

    res.json({ createdInvoice });
  } catch (error) {
    res.status(400).json(error.message);
    console.error(error.message);
  }
};

const getAllSaleInvoice = async (req, res) => {
  try {
    let aggregations, saleInvoices;

    const { skip, limit } = getPagination(req.query);

    if (req.query.query === 'info') {
      aggregations = await SaleInvoice.aggregate([
        { $count: "id" },
        {
          $group: {
            _id: null,
            total_amount: { $sum: "$total_amount" },
            discount: { $sum: "$discount" },
            due_amount: { $sum: "$due_amount" },
            paid_amount: { $sum: "$paid_amount" },
            profit: { $sum: "$profit" },
          }
        }
      ]);
      res.json(aggregations);
    } else {
      if (req.query.user) {
        saleInvoices = await SaleInvoice.find({
          user: req.query.user,
          date: { $gte: new Date(req.query.startdate), $lte: new Date(req.query.enddate) }
        })
          .skip(Number(skip))
          .limit(Number(limit))
          .sort({ _id: -1 })
          .populate('saleInvoiceProduct.product')
          .populate('customer', 'name')
          .populate('user', 'nom');
      } else {
        saleInvoices = await SaleInvoice.find({
          date: { $gte: new Date(req.query.startdate), $lte: new Date(req.query.enddate) }
        })
          .skip(Number(skip))
          .limit(Number(limit))
          .sort({ _id: -1 })
          .populate('saleInvoiceProduct.product')
          .populate('customer', 'name')
          .populate('user', 'nom');
      }
      res.json({ aggregations, saleInvoices });
    }
  } catch (error) {
    res.status(400).json(error.message);
    console.error(error.message);
  }
};


const getSingleSaleInvoice = async (req, res) => {
  try {
    const singleSaleInvoice = await SaleInvoice.findById(req.params.id)
      .populate('saleInvoiceProduct.product')
      .populate('customer')
      .populate('user', 'nom');

    const transactions = await Transaction.find({
      related_id: req.params.id,
      type: { $in: ['sale', 'sale_return'] }
    });

    // Process transactions and other logic as in the original function

    res.json({ singleSaleInvoice, transactions });
  } catch (error) {
    res.status(400).json(error.message);
    console.error(error.message);
  }
};



module.exports = {
  createSingleSaleInvoice,
  getAllSaleInvoice,
  getSingleSaleInvoice,
};
