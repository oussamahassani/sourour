const mongoose = require("mongoose");
const SaleInvoice = require("../../models/SaleInvoice");
const PurchaseInvoice = require("../../models/PurchaseInvoice");
const Customer = require("../../models/Client");

const getDashboardData = async (req, res) => {
  try {
    const startDate = new Date(req.query.startdate);
    const endDate = new Date(req.query.enddate);

    // ========================== saleProfitCount ==========================
    const allSaleInvoice = await SaleInvoice.aggregate([
      {
        $match: {
          date: { $gte: startDate, $lte: endDate },
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: "%Y-%m-%d", date: "$date" },
          },
          total_amount: { $sum: "$total_amount" },
          paid_amount: { $sum: "$paid_amount" },
          due_amount: { $sum: "$due_amount" },
          profit: { $sum: "$profit" },
          count: { $sum: 1 },
        },
      },
      { $sort: { "_id": 1 } },
    ]);

    const formattedData1 = allSaleInvoice.map((item) => ({
      type: "Sales",
      date: item._id,
      amount: item.total_amount,
    }));

    const formattedData2 = allSaleInvoice.map((item) => ({
      type: "Profit",
      date: item._id,
      amount: item.profit,
    }));

    const formattedData3 = allSaleInvoice.map((item) => ({
      type: "Invoice Count",
      date: item._id,
      amount: item.count,
    }));

    const saleProfitCount = [...formattedData1, ...formattedData2, ...formattedData3];

    // ========================== PurchaseVSSale ==========================
    const salesInfo = await SaleInvoice.aggregate([
      {
        $group: {
          _id: null,
          total_amount: { $sum: "$total_amount" },
          count: { $sum: 1 },
        },
      },
    ]);

    const purchasesInfo = await PurchaseInvoice.aggregate([
      {
        $group: {
          _id: null,
          total_amount: { $sum: "$total_amount" },
          count: { $sum: 1 },
        },
      },
    ]);

    const formattedData4 = [
      { type: "sales", value: salesInfo[0]?.total_amount || 0 },
    ];
    const formattedData5 = [
      { type: "purchases", value: purchasesInfo[0]?.total_amount || 0 },
    ];
    const SupplierVSCustomer = [...formattedData4, ...formattedData5];

    // ========================== customerSaleProfit ==========================
    const allSaleInvoiceByGroup = await SaleInvoice.aggregate([
      {
        $match: {
          date: { $gte: startDate, $lte: endDate },
        },
      },
      {
        $group: {
          _id: "$customer_id",
          total_amount: { $sum: "$total_amount" },
          profit: { $sum: "$profit" },
          count: { $sum: 1 },
        },
      },
    ]);

    const formattedData6 = await Promise.all(
      allSaleInvoiceByGroup.map(async (item) => {
        const customer = await Customer.findById(item._id);
        return {
          label: customer?.nom || "Unknown",
          type: "Sales",
          value: item.plafond_credit,
        };
      })
    );

    const formattedData7 = await Promise.all(
      allSaleInvoiceByGroup.map(async (item) => {
        const customer = await Customer.findById(item._id);
        return {
          label: customer?.nom || "Unknown",
          type: "Profit",
          value: item.cin,
        };
      })
    );

    const customerSaleProfit = [...formattedData6, ...formattedData7].sort(
      (a, b) => b.value - a.value
    );

    // ========================== cardInfo ==========================
    const purchaseInfo = await PurchaseInvoice.aggregate([
      {
        $match: {
          date: { $gte: startDate, $lte: endDate },
        },
      },
      {
        $group: {
          _id: null,
          count: { $sum: 1 },
          total_amount: { $sum: "$total_amount" },
          due_amount: { $sum: "$due_amount" },
          paid_amount: { $sum: "$paid_amount" },
        },
      },
    ]);

    const saleInfo = await SaleInvoice.aggregate([
      {
        $match: {
          date: { $gte: startDate, $lte: endDate },
        },
      },
      {
        $group: {
          _id: null,
          count: { $sum: 1 },
          total_amount: { $sum: "$total_amount" },
          due_amount: { $sum: "$due_amount" },
          paid_amount: { $sum: "$paid_amount" },
          profit: { $sum: "$profit" },
        },
      },
    ]);

    const cardInfo = {
      purchase_count: purchaseInfo[0]?.count || 0,
      purchase_total: purchaseInfo[0]?.total_amount || 0,
      sale_count: saleInfo[0]?.count || 0,
      sale_total: saleInfo[0]?.total_amount || 0,
      sale_profit: saleInfo[0]?.profit || 0,
    };

    res.json({
      saleProfitCount,
      SupplierVSCustomer,
      customerSaleProfit,
      cardInfo,
    });
  } catch (error) {
    console.log("Dashboard Error:", error.message);
    res.status(400).json({ message: error.message });
  }
};

module.exports = { getDashboardData };
