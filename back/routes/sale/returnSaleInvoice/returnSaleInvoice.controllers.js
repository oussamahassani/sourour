const Product = require('../../../models/Article');
const SaleInvoice = require('../../../models/SaleInvoice');
const ReturnSaleInvoice = require('../../../models/ReturnSaleInvoice');

const createSingleReturnSaleInvoice = async (req, res) => {
  try {
    // Calcul du prix total de vente
    const totalSalePrice = req.body.returnSaleInvoiceProduct.reduce((total, item) => {
      return total + item.product_sale_price * item.product_quantity;
    }, 0);

    // Récupération des produits associés
    const productIds = req.body.returnSaleInvoiceProduct.map(item => item.product_id);
    const products = await Product.find({ '_id': { $in: productIds } });

    // Calcul du prix total d'achat
    const totalPurchasePrice = req.body.returnSaleInvoiceProduct.reduce((total, item, index) => {
      return total + products[index].purchasePrice * item.product_quantity;
    }, 0);

    // Récupération de la facture de vente associée
    const saleInvoice = await SaleInvoice.findById(req.body.saleInvoice_id)
      .populate('products')
      .exec();

    // Calcul du montant dû
    const dueAmount = saleInvoice.totalAmount - saleInvoice.discount - totalSalePrice;

    // Création de la facture de retour
    const returnSaleInvoice = new ReturnSaleInvoice({
      saleInvoiceId: req.body.saleInvoice_id,
      totalAmount: totalSalePrice,
      products: productIds,
      date: new Date(req.body.date),
      note: req.body.note,
      status: false,
    });

    await returnSaleInvoice.save();

    // Mise à jour des stocks
    req.body.returnSaleInvoiceProduct.forEach(async (item) => {
      await Product.findByIdAndUpdate(item.product_id, {
        $inc: { quantity: item.product_quantity },
      });
    });

    // Mise à jour du profit de la facture de vente
    const returnSaleInvoiceProfit = totalSalePrice - totalPurchasePrice;
    await SaleInvoice.findByIdAndUpdate(req.body.saleInvoice_id, {
      $inc: { profit: -returnSaleInvoiceProfit },
    });

    res.json({ returnSaleInvoice });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const getAllReturnSaleInvoice = async (req, res) => {
  try {
    const filters = {};
    if (req.query.startdate && req.query.enddate) {
      filters.date = {
        $gte: new Date(req.query.startdate),
        $lte: new Date(req.query.enddate),
      };
    }
    if (req.query.status) {
      filters.status = req.query.status === 'true';
    }

    const returnSaleInvoices = await ReturnSaleInvoice.find(filters)
      .populate('saleInvoiceId')
      .exec();

    res.json(returnSaleInvoices);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};


const getSingleReturnSaleInvoice = async (req, res) => {
  try {
    const returnSaleInvoice = await ReturnSaleInvoice.findById(req.params.id)
      .populate('saleInvoiceId')
      .exec();

    res.json(returnSaleInvoice);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};
const updateSingleReturnSaleInvoice = async (req, res) => {
  try {
    const updatedReturnSaleInvoice = await ReturnSaleInvoice.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );

    res.json(updatedReturnSaleInvoice);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const deleteSingleReturnSaleInvoice = async (req, res) => {
  try {
    const returnSaleInvoice = await ReturnSaleInvoice.findById(req.params.id).exec();

    // Mise à jour des stocks
    returnSaleInvoice.products.forEach(async (productId) => {
      await Product.findByIdAndUpdate(productId, {
        $inc: { quantity: -1 },
      });
    });

    // Suppression de la facture de retour
    await ReturnSaleInvoice.findByIdAndDelete(req.params.id);

    res.json({ message: 'Return sale invoice deleted successfully' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};


module.exports = {
  createSingleReturnSaleInvoice,
  getAllReturnSaleInvoice,
  getSingleReturnSaleInvoice,
  updateSingleReturnSaleInvoice,
  deleteSingleReturnSaleInvoice,
};
