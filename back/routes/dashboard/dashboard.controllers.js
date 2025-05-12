const mongoose = require("mongoose");
const SaleInvoice = require("../../models/Achat");
const BaysInvoice = require("../../models/Vente");
const User = require("../../models/User");
const Customer = require("../../models/Client");

const getDashboardMobileData = async (req, res) => {
  const totalTTcAchat = await SaleInvoice.aggregate([
    {
      $group: {
        _id: null,
        totalPrixTTC: { $sum: "$prix_ttc" }
      }
    }
  ])
  const totalTvaAchat = await SaleInvoice.aggregate([
    {
      $group: {
        _id: null,
        tva: { $sum: "$TVA" }
      }
    }
  ])
  const totalTvaBys =  await SaleInvoice.aggregate([
    {
      $group: {
        _id: null,
        tva: { $sum: "$TVA" }
      }
    }
  ])
  const totalTTcBayes = await BaysInvoice.aggregate([
    {
      $group: {
        _id: null,
        totalPrixTTC: { $sum: "$prix_ttc" }
      }
    }
  ])
let data = {}
if(totalTTcAchat && totalTTcAchat.length> 0){
  data.totalTTcAchat = totalTTcAchat[0].totalPrixTTC
}
if(totalTTcBayes && totalTTcBayes.length> 0){
  data.totalTTcVente = totalTTcBayes[0].totalPrixTTC
}
let sumTva = 0
if(totalTvaBys && totalTvaBys.length> 0){
  sumTva = totalTvaBys[0].tva
}
if(totalTvaAchat && totalTvaAchat.length> 0){
  sumTva += totalTvaAchat[0].tva
}
data.sumTva = sumTva;
  res.json(data);
}
const getDashboardData = async (req, res) => {
  try {
    const startDate = new Date(req.query.startdate);
    const endDate = new Date(req.query.enddate);

    // ========================== saleProfitCount ==========================
    const allSaleInvoice = await SaleInvoice.aggregate([
      {
        $match: {
          date_achat: { $gte: startDate, $lte: endDate },
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: "%Y-%m-%d", date: "$date_achat" },
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
      type: "Direct",
      date: item._id,
      amount: item.paid_amount,
    }));

    const formattedData2 = allSaleInvoice.map((item) => ({
      type: "Commandé",
      date: item._id,
      amount: item.paid_amount,
    }));



    const saleProfitCount = [...formattedData1, ...formattedData2,];

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





    const customer = (await Customer.find()).map(el => {
      return {
        label: el?.nom || "Unknown",
        type: el?.plafond_credit,
        value: el.cin,
      }
    }
    )


    const UserInfo = (await User.find().limit(10)).map(el => {
      return {
        label: el?.nom || "Unknown",
        role: el.role,
      }
    }
    )
    const UserInfoLength = (await User.find().countDocuments())
    // ========================== cardInfo ==========================




    const cardInfo = {

      sale_count: allSaleInvoice[0]?.count || 0,
      sale_total: allSaleInvoice[0]?.total_amount || 0,
      sale_profit: customer.length || 0,
      userlength: UserInfoLength
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

module.exports = { getDashboardData,getDashboardMobileData };
