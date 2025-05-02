const express = require("express");
const {
  createSingleRole,
  getAllRole,
  getSingleRole,
  updateSingleRole,
  deleteSingleRole,
} = require("../controllers/role.controllers");
const { getAllPermission } = require("../controllers/permission.controllers");

const authorize = require("../utils/autorize"); // authentication middleware

const roleRoutes = express.Router();
// authorize("createRole")
roleRoutes.post("/", createSingleRole);
// authorize("viewRole")
roleRoutes.get("/", getAllRole);
//authorize("viewRole")
roleRoutes.get("/:id", getSingleRole);
//authorize("updateRole")
roleRoutes.put("/:id",  updateSingleRole);

// authorize("viewPermission")
roleRoutes.get("/premission/all", getAllPermission);

roleRoutes.patch("/:id", authorize("deleteRole"), deleteSingleRole);

module.exports = roleRoutes;