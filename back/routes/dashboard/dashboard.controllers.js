const mongoose = require("mongoose");
const SaleInvoice = require("../../models/Achat");
const User = require("../../models/User");
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
          total_amount: { $sum: "$prix_achatTTC" },
          paid_amount: { $sum: "$prix_achatHT" },
          due_amount: { $sum: "$quantité" },
          count: { $sum: 1 },
        },
      },
      { $sort: { "_id": 1 } },
    ]);

    const formattedData1 = allSaleInvoice.map((item) => ({
      type_achat: "Direct",
      date: item._id,
      amount: item.prix_achatHT,
    }));

    const formattedData2 = allSaleInvoice.map((item) => ({
      type: "Commandé",
      date: item._id,
      amount: item.prix_achatHT,
    }));



    const saleProfitCount = [...formattedData1, ...formattedData2, ];

    // ========================== PurchaseVSSale ==========================
    const salesInfo = await SaleInvoice.aggregate([
      {
        $group: {
          _id: null,
          total_amount: { $sum: "$prix_achatTTC" },
          count: { $sum: 1 },
        },
      },
    ]);



    const formattedData4 = [
      { type: "sales", value: salesInfo[0]?.total_amount || 0 },
    ];

    const SupplierVSCustomer = [...formattedData4];

    // ========================== customerSaleProfit ==========================
   

  

   
        const customer = (await Customer.find()).map(el  =>{
        return {
          label: el?.nom || "Unknown",
          type: "Profit",
          value: el.cin,
        }
      }
      )
    

    const UserInfo =(await User.find()).map(el  =>{
      return {
        label: el?.nom || "Unknown",
        type: "Profit",
        value: el.cin,
      }
    }
    )

    // ========================== cardInfo ==========================


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
  
      sale_count: saleInfo[0]?.count || 0,
      sale_total: saleInfo[0]?.total_amount || 0,
      sale_profit: saleInfo[0]?.profit || 0,
    };

    res.json({
      saleProfitCount,
      SupplierVSCustomer,
      UserInfo,
      cardInfo,
      customer
    });
  } catch (error) {
    console.log("Dashboard Error:", error.message);
    res.status(400).json({ message: error.message });
  }
};

module.exports = { getDashboardData };
