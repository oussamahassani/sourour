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
