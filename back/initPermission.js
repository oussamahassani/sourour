const Permission = require("./models/Permission"); // ajuste le chemin si nécessaire

const defaultPermissions = [
  { name: "view_users" },
  { name: "edit_roles" },
  { name: "delete_data" },
  { name: "manage_permissions" },
  { name: "viewPermission" },
  { name: "updateRole" },
  { name: "viewRole" },
  { name: "createRole" },
  { name: "manageUser" },
  { name: "managecustomer" },
  { name: "viewBrDATA" },
  { name: "viewProdact" },
  { name: "viewDashboard" },
  { name: "createPaymentPurchaseInvoice" },
  { name: "viewPaymentPurchaseInvoice" },
  { name: "updateSetting" },
  { name: "viewSetting" },
  { name: "createSaleInvoice" },
  { name: "viewSaleInvoice" },
  { name: "createReturnSaleInvoice" },
  { name: "viewReturnSaleInvoice" },
  { name: "deleteReturnSaleInvoice" },
  { name: "createPaymentSaleInvoice" },
  { name: "viewPaymentSaleInvoice" },
  { name: "createReturnPurchaseInvoice" },
  { name: "viewReturnPurchaseInvoice" },
  { name: "deleteReturnPurchaseInvoice" },
  { name: "createPurchaseInvoice" },
  { name: "viewPurchaseInvoice" },

];

async function initPermissions() {
  try {
    await Permission.insertMany(defaultPermissions, { ordered: false });
    console.log("✅ Permissions initialized successfully.");
  } catch (error) {
    if (error.code === 11000) {
      console.log("⚠️ Some permissions already exist, skipped duplicates.");
    } else {
      console.error("❌ Error inserting permissions:", error.message);
    }
  }
}

module.exports = initPermissions;
