const mongoose = require("mongoose");
const Transaction = require("../../../models/Transaction");
const Product = require("../../../models/Article");
const PurchaseInvoice = require("../../../models/PurchaseInvoice");
const ReturnPurchaseInvoice = require("../../../models/ReturnPurchaseInvoice");
const getPagination = require("../../../utils/pagination")
const createSinglePurchaseInvoice = async (req, res) => {
  try {
    // 1. Calculer le total d'achat
    let totalPurchasePrice = 0;
    req.body.purchaseInvoiceProduct.forEach((item) => {
      totalPurchasePrice += parseFloat(item.product_purchase_price) * parseFloat(item.product_quantity);
    });

    const date = new Date(req.body.date);
    const discount = parseFloat(req.body.discount);
    const paidAmount = parseFloat(req.body.paid_amount);
    const dueAmount = totalPurchasePrice - discount - paidAmount;

    // 2. Créer une nouvelle facture d'achat
    const newInvoice = new PurchaseInvoice({
      date,
      total_amount: totalPurchasePrice,
      discount: discount,
      paid_amount: paidAmount,
      due_amount: dueAmount,
      supplier_id: new mongoose.Types.ObjectId(req.body.supplier_id),
      note: req.body.note,
      supplier_memo_no: req.body.supplier_memo_no,
      purchaseInvoiceProduct: req.body.purchaseInvoiceProduct.map((product) => ({
        product_id: new mongoose.Types.ObjectId(product.product_id),
        product_quantity: Number(product.product_quantity),
        product_purchase_price: parseFloat(product.product_purchase_price),
      })),
    });

    const createdInvoice = await newInvoice.save();

    // 3. Créer une transaction de paiement (si payé)
    if (paidAmount > 0) {
      await new Transaction({
        date,
        debit_id: "3", // Exemple d'ID de compte débité
        credit_id: "1", // Exemple d'ID de compte crédité
        amount: paidAmount,
        particulars: `Cash paid on Purchase Invoice #${createdInvoice._id}`,
        type: "purchase",
        related_id: createdInvoice._id,
      }).save();
    }

    // 4. Créer une transaction pour la dette (si dû)
    if (dueAmount > 0) {
      await new Transaction({
        date,
        debit_id: "3",
        credit_id: "5",
        amount: dueAmount,
        particulars: `Due on Purchase Invoice #${createdInvoice._id}`,
        type: "purchase",
        related_id: createdInvoice._id,
      }).save();
    }

    // 5. Mettre à jour les produits
    for (const item of req.body.purchaseInvoiceProduct) {
      await Product.updateOne(
        { _id: new mongoose.Types.ObjectId(item.product_id) },
        {
          $inc: { quantity: Number(item.product_quantity) },
          $set: { purchase_price: parseFloat(item.product_purchase_price) },
        }
      );
    }

    res.json({
      createdInvoice,
    });
  } catch (error) {
    console.error(error.message);
    res.status(500).json({ error: error.message });
  }
};

const getAllPurchaseInvoice = async (req, res) => {
  if (req.query.query === 'info') {
    // Agrégations pour obtenir les totaux
    try {
      const aggregations = await PurchaseInvoice.aggregate([
        {
          $match: {
            date: {
              $gte: new Date(req.query.startdate),
              $lte: new Date(req.query.enddate)
            }
          }
        },
        {
          $group: {
            _id: null,
            totalAmount: { $sum: '$total_amount' },
            dueAmount: { $sum: '$due_amount' },
            paidAmount: { $sum: '$paid_amount' },
            count: { $sum: 1 }
          }
        }
      ]);
      res.json(aggregations[0] || { totalAmount: 0, dueAmount: 0, paidAmount: 0, count: 0 });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  } else {
    const { skip, limit } = getPagination(req.query);

    try {
      const [aggregations, purchaseInvoices] = await Promise.all([
        // Agrégation pour obtenir les totaux des factures d'achat
        PurchaseInvoice.aggregate([
          {
            $match: {
              date: {
                $gte: new Date(req.query.startdate),
                $lte: new Date(req.query.enddate)
              }
            }
          },
          {
            $group: {
              _id: null,
              totalAmount: { $sum: '$total_amount' },
              discount: { $sum: '$discount' },
              dueAmount: { $sum: '$due_amount' },
              paidAmount: { $sum: '$paid_amount' }
            }
          }
        ]),
        // Pagination des factures d'achat
        PurchaseInvoice.find({
          date: {
            $gte: new Date(req.query.startdate),
            $lte: new Date(req.query.enddate)
          }
        })
          .skip(Number(skip))
          .limit(Number(limit))
          .populate('supplier', 'nom')
      ]);

      // Obtenez les transactions liées à ces factures
      const transactions = await Transaction.find({
        type: 'purchase',
        related_id: { $in: purchaseInvoices.map((item) => item._id) },
        $or: [{ credit_id: 1 }, { credit_id: 2 }]
      });

      // Transactions liées aux retours de facture
      const transactions2 = await Transaction.find({
        type: 'purchase_return',
        related_id: { $in: purchaseInvoices.map((item) => item._id) },
        $or: [{ debit_id: 1 }, { debit_id: 2 }]
      });

      // Transactions liées aux remises (réductions)
      const transactions3 = await Transaction.find({
        type: 'purchase',
        related_id: { $in: purchaseInvoices.map((item) => item._id) },
        credit_id: 13
      });

      // Retour de la facture d'achat
      const returnPurchaseInvoice = await ReturnPurchaseInvoice.find({
        purchaseInvoice_id: { $in: purchaseInvoices.map((item) => item._id) }
      });

      // Calculs des montants payés, des retours, des remises, etc.
      const allPurchaseInvoice = purchaseInvoices.map((item) => {
        const paidAmount = transactions
          .filter((transaction) => transaction.related_id.equals(item._id))
          .reduce((acc, curr) => acc + curr.amount, 0);

        const paidAmountReturn = transactions2
          .filter((transaction) => transaction.related_id.equals(item._id))
          .reduce((acc, curr) => acc + curr.amount, 0);

        const discountEarned = transactions3
          .filter((transaction) => transaction.related_id.equals(item._id))
          .reduce((acc, curr) => acc + curr.amount, 0);

        const returnAmount = returnPurchaseInvoice
          .filter((returnInvoice) => returnInvoice.purchaseInvoice_id.equals(item._id))
          .reduce((acc, curr) => acc + curr.total_amount, 0);

        return {
          ...item.toObject(),
          paid_amount: paidAmount,
          discount: item.discount + discountEarned,
          due_amount:
            item.total_amount - item.discount - paidAmount - returnAmount + paidAmountReturn - discountEarned
        };
      });

      // Calcul des totaux
      const totalPaidAmount = allPurchaseInvoice.reduce((acc, curr) => acc + curr.paid_amount, 0);
      const totalDueAmount = allPurchaseInvoice.reduce((acc, curr) => acc + curr.due_amount, 0);
      const totalDiscountGiven = allPurchaseInvoice.reduce((acc, curr) => acc + curr.discount, 0);
      if (aggregations[0]) {


        aggregations[0].paidAmount = totalPaidAmount;
        aggregations[0].dueAmount = totalDueAmount;
        aggregations[0].discount = totalDiscountGiven;
      }
      res.json({
        aggregations: aggregations[0],
        allPurchaseInvoice
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
      console.log(error);
    }
  }
};


const getSinglePurchaseInvoice = async (req, res) => {
  try {
    const invoiceId = new mongoose.Types.ObjectId(req.params.id);

    // 1. Obtenez la facture d'achat avec les produits associés
    const singlePurchaseInvoice = await PurchaseInvoice.findById(invoiceId)

      .populate('supplier', 'nom'); // Définir ce que vous voulez pour le fournisseur

    // 2. Obtenez toutes les transactions liées à cette facture
    const transactions = await Transaction.find({
      related_id: invoiceId,
      $or: [{ type: "purchase" }, { type: "purchase_return" }],
    })


    // 3. Transactions liées au paiement de la facture (paiement reçu)
    const transactions2 = await Transaction.find({
      type: "purchase",
      related_id: invoiceId,
      $or: [{ credit_id: 1 }, { credit_id: 2 }],
    });

    // 4. Transactions liées aux remises (réductions)
    const transactions3 = await Transaction.find({
      type: "purchase",
      related_id: invoiceId,
      credit_id: 13,
    });

    // 5. Transactions liées aux retours de facture d'achat
    const transactions4 = await Transaction.find({
      type: "purchase_return",
      related_id: invoiceId,
      $or: [{ debit_id: 1 }, { debit_id: 2 }],
    });

    // 6. Obtenez les retours de facture d'achat
    const returnPurchaseInvoice = await ReturnPurchaseInvoice.find({
      purchaseInvoice_id: invoiceId,
    })


    // 7. Calcul des montants totaux
    const totalPaidAmount = transactions2.reduce((acc, item) => acc + item.amount, 0);
    const totalDiscountAmount = transactions3.reduce((acc, item) => acc + item.amount, 0);
    const paidAmountReturn = transactions4.reduce((acc, curr) => acc + curr.amount, 0);
    const totalReturnAmount = returnPurchaseInvoice.reduce((acc, item) => acc + item.total_amount, 0);

    // 8. Calcul du montant dû
    const dueAmount =
      singlePurchaseInvoice.total_amount -
      singlePurchaseInvoice.discount -
      totalPaidAmount -
      totalDiscountAmount -
      totalReturnAmount +
      paidAmountReturn;

    let status = "UNPAID";
    if (dueAmount === 0) {
      status = "PAID";
    }

    // 9. Renvoyer les résultats
    res.json({
      status,
      totalPaidAmount,
      totalReturnAmount,
      dueAmount,
      singlePurchaseInvoice,
      returnPurchaseInvoice,
      transactions,
    });
  } catch (error) {
    console.error(error.message);
    res.status(400).json({ error: error.message });
  }
};


module.exports = {
  createSinglePurchaseInvoice,
  getAllPurchaseInvoice,
  getSinglePurchaseInvoice,
};
