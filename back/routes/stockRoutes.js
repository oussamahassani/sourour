const express = require('express');
const router = express.Router();
const StockController = require('../controllers/stock.contoller');

// Routes pour le stock
router.post('/create', StockController.createStock);
router.get('/', StockController.getAllStocks);
router.get('/:id_stock', StockController.getStockById);
router.put('/:id_stock', StockController.updateStock);
router.delete('/:id_stock', StockController.deleteStock);
router.post('/entry', StockController.addStockEntry);
router.post('/exit', StockController.addStockExit);
router.get('/replenish', StockController.checkReplenishment);

module.exports = router;
