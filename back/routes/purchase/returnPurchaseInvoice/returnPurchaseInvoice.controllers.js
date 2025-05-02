
const Product = require('../../../models/Article');
const Supplier = require('../../../models/Fournisseur');
const Transaction = require('../../../models/Transaction');
const ReturnPurchaseInvoice = require('../../../models/ReturnPurchaseInvoice');
const PurchaseInvoice = require('../../../models/PurchaseInvoice');

const createSingleReturnPurchaseInvoice = async (req, res) => {

  try {
    // Calculate total purchase price
    let totalPurchasePrice = 0;
    req.body.returnPurchaseInvoiceProduct.forEach((item) => {
      totalPurchasePrice += parseFloat(item.product_purchase_price) * parseFloat(item.product_quantity);
    });

    // ============ DUE AMOUNT CALCULATION START==============================================
    // Get single purchase invoice information
    const singlePurchaseInvoice = await PurchaseInvoice.findById(req.body.purchaseInvoice_id);
    if (!singlePurchaseInvoice) {
      return res.status(404).json({ message: 'Purchase Invoice not found' });
    }

    // Transactions of the paid amount
    const transactions2 = await Transaction.find({
      type: 'purchase',
      related_id: req.body.purchaseInvoice_id,
      $or: [
        { credit_id: 1 },
        { credit_id: 2 }
      ]
    });

    // Transactions of the discount earned amount
    const transactions3 = await Transaction.find({
      type: 'purchase',
      related_id: req.body.purchaseInvoice_id,
      credit_id: 13
    });

    // Transactions of the return purchase invoice's amount
    const transactions4 = await Transaction.find({
      type: 'purchase_return',
      related_id: req.body.purchaseInvoice_id,
      $or: [
        { debit_id: 1 },
        { debit_id: 2 }
      ]
    });

    // Get return purchase invoice information with products
    const returnPurchaseInvoice = await ReturnPurchaseInvoice.find({ purchaseInvoice_id: req.body.purchaseInvoice_id });

    // Sum of total paid amount, discount, return purchase invoice, etc.
    const totalPaidAmount = transactions2.reduce((acc, item) => acc + item.amount, 0);
    const totalDiscountAmount = transactions3.reduce((acc, item) => acc + item.amount, 0);
    const paidAmountReturn = transactions4.reduce((acc, curr) => acc + curr.amount, 0);
    const totalReturnAmount = returnPurchaseInvoice.reduce((acc, item) => acc + item.total_amount, 0);

    const dueAmount = singlePurchaseInvoice.total_amount - singlePurchaseInvoice.discount - totalPaidAmount - totalDiscountAmount - totalReturnAmount + paidAmountReturn;

    // ============ DUE AMOUNT CALCULATION END===============================================

    // Convert all incoming data to the correct format
    const date = new Date(req.body.date).toISOString().split('T')[0];

    // Create return purchase invoice
    const createdReturnPurchaseInvoice = await ReturnPurchaseInvoice.create([{
      date: new Date(date),
      total_amount: totalPurchasePrice,
      purchaseInvoice: req.body.purchaseInvoice_id,
      note: req.body.note,
      returnPurchaseInvoiceProduct: req.body.returnPurchaseInvoiceProduct.map((product) => ({
        product: product.product_id,
        product_quantity: product.product_quantity,
        product_purchase_price: parseFloat(product.product_purchase_price)
      }))
    }], { session });

    // Receive payment from supplier on return purchase transaction create
    if (dueAmount >= totalPurchasePrice) {
      await Transaction.create([{
        date: new Date(date),
        debit_id: 5,  // Dynamic debit_id like bank, cash, etc.
        credit_id: 3, // Assuming account payable or a similar credit ID
        amount: totalPurchasePrice,
        particulars: `Account payable (due) reduced on Purchase return invoice #${createdReturnPurchaseInvoice.id} of purchase invoice #${req.body.purchaseInvoice_id}`,
        type: 'purchase_return',
        related_id: req.body.purchaseInvoice_id
      }], { session });
    } else {
      await Transaction.create([{
        date: new Date(date),
        debit_id: 5,  // Dynamic debit_id like bank, cash, etc.
        credit_id: 3, // Assuming account payable or a similar credit ID
        amount: dueAmount,
        particulars: `Account payable (due) reduced on Purchase return invoice #${createdReturnPurchaseInvoice.id} of purchase invoice #${req.body.purchaseInvoice_id}`,
        type: 'purchase_return',
        related_id: req.body.purchaseInvoice_id
      }], { session });

      await Transaction.create([{
        date: new Date(date),
        debit_id: 1,  // Dynamic debit_id for cash or similar
        credit_id: 3, // Assuming bank or cash for the credit side
        amount: totalPurchasePrice - dueAmount,
        particulars: `Cash received on Purchase return invoice #${createdReturnPurchaseInvoice.id} of purchase invoice #${req.body.purchaseInvoice_id}`,
        type: 'purchase_return',
        related_id: req.body.purchaseInvoice_id
      }], { session });
    }

    // Iterate through all products and decrease product quantity
    for (const item of req.body.returnPurchaseInvoiceProduct) {
      await Product.findByIdAndUpdate(item.product_id, {
        $inc: { quantity: -item.product_quantity }
      }, { session });
    }

    // Commit the transaction
    await session.commitTransaction();
    session.endSession();

    res.json({
      createdReturnPurchaseInvoice
    });
  } catch (error) {
    // If an error occurs, abort the transaction
    await session.abortTransaction();
    session.endSession();

    res.status(400).json({ error: error.message });
    console.log(error.message);
  }
};


const getAllReturnPurchaseInvoice = async (req, res) => {
  const { query, status, startdate, enddate } = req.query;

  try {
    const matchStage = {
      $match: {
        ...(startdate && enddate
          ? {
            date: {
              $gte: new Date(startdate),
              $lte: new Date(enddate),
            },
          }
          : {}),
        ...(status !== undefined ? { status: status === "true" } : {}),
      },
    };

    const groupStage = {
      $group: {
        _id: { $dateToString: { format: "%Y-%m-%d", date: "$date" } },
        totalAmount: { $sum: "$total_amount" },
        count: { $sum: 1 },
      },
    };

    const aggregationPipeline = [matchStage, groupStage];

    if (query === "group") {
      const result = await ReturnPurchaseInvoice.aggregate(aggregationPipeline);
      return res.json(result);
    }

    if (query === "info") {
      const info = await ReturnPurchaseInvoice.aggregate([
        matchStage,
        { $count: "totalCount" },
        { $project: { _id: 0, totalCount: 1 } },
      ]);
      return res.json(info);
    }

    if (query === "all") {
      const allInvoices = await ReturnPurchaseInvoice.find(matchStage.$match);
      return res.json(allInvoices);
    }

    res.status(400).json({ error: "Invalid query parameter" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};



const getSingleReturnPurchaseInvoice = async (req, res) => {
  try {
    const { id } = req.params;

    const invoice = await ReturnPurchaseInvoice.findById(id)
      .populate({
        path: 'returnPurchaseInvoiceProduct.product_id',
        model: 'Product',
      })
      .populate('purchaseInvoice_id');

    if (!invoice) {
      return res.status(404).json({ error: 'Return purchase invoice not found' });
    }

    res.json(invoice);
  } catch (error) {
    console.error(error.message);
    res.status(400).json({ error: error.message });
  }
};




const updateSingleReturnPurchaseInvoice = async (req, res) => {
  try {
    const { id } = req.params;

    const updatedInvoice = await ReturnPurchaseInvoice.findByIdAndUpdate(
      id,
      {
        name: req.body.name,
        quantity: Number(req.body.quantity),
        purchase_price: Number(req.body.purchase_price),
        sale_price: Number(req.body.sale_price),
        note: req.body.note,
      },
      { new: true } // return the updated document
    );

    if (!updatedInvoice) {
      return res.status(404).json({ error: 'Return purchase invoice not found' });
    }

    res.json(updatedInvoice);
  } catch (error) {
    console.error(error.message);
    res.status(400).json({ error: error.message });
  }
};



const deleteSingleReturnPurchaseInvoice = async (req, res) => {


  try {
    // Récupérer les détails de la facture de retour
    const returnPurchaseInvoice = await ReturnPurchaseInvoice.findOne({ _id: req.params.id }).populate('returnPurchaseInvoiceProduct.product').populate('supplier_id');

    if (!returnPurchaseInvoice) {
      return res.status(404).json({ message: 'Return Purchase Invoice not found' });
    }

    // Mettre à jour la quantité des produits en réduisant les quantités
    for (const item of returnPurchaseInvoice.returnPurchaseInvoiceProduct) {
      await Product.findByIdAndUpdate(
        item.product._id,
        {
          $inc: { quantity: -item.product_quantity }
        },
        { session }
      );
    }

    // Mettre à jour l'état de la facture de retour d'achat
    const deletedInvoice = await ReturnPurchaseInvoice.findByIdAndUpdate(
      req.params.id,
      {
        status: req.body.status
      },
      { new: true, session }
    );

    // Mettre à jour le montant dû du fournisseur (si nécessaire)
    // Vous pouvez choisir de décommenter cette section si vous devez diminuer le montant dû du fournisseur.
    // const updatedSupplier = await Supplier.findByIdAndUpdate(
    //   returnPurchaseInvoice.supplier_id,
    //   {
    //     $inc: { due_amount: -returnPurchaseInvoice.due_amount }
    //   },
    //   { session }
    // );

    // Créer une transaction pour refléter l'annulation du paiement de la facture de retour
    const newTransaction = await Transaction.create(
      [{
        date: new Date(),
        type: 'purchase_deleted',
        related_id: returnPurchaseInvoice._id,
        amount: returnPurchaseInvoice.paid_amount,
        particulars: 'Paid amount refunded',
      }],
      { session }
    );


    res.json({
      deletedInvoice,
      transaction: newTransaction,
      // supplier: updatedSupplier // Si vous décommentez la mise à jour du fournisseur
    });
  } catch (error) {
    // Si une erreur se produit, annuler la transaction

    res.status(400).json({ error: error.message });
    console.log(error.message);
  }
};

module.exports = deleteSingleReturnPurchaseInvoice;



module.exports = {
  createSingleReturnPurchaseInvoice,
  getAllReturnPurchaseInvoice,
  getSingleReturnPurchaseInvoice,
  updateSingleReturnPurchaseInvoice,
  deleteSingleReturnPurchaseInvoice,
};
