const express = require("express");
const {
  createRolePermission,
  getAllRolePermission,
  getSingleRolePermission,
  updateRolePermission,
  deleteSingleRolePermission,
} = require("../controllers/rolePermission.controllers");
const authorize = require("../utils/autorize"); // authentication middleware

const rolePermissionRoutes = express.Router();

rolePermissionRoutes.post(
  "/",
  authorize("createRolePermission"),
  createRolePermission
);
rolePermissionRoutes.get(
  "/",
 authorize("viewRolePermission"),
  getAllRolePermission
);
rolePermissionRoutes.get(
  "/:id",
  authorize("viewRolePermission"),
  getSingleRolePermission
);
rolePermissionRoutes.put(
  "/:id",
  authorize("updateRolePermission"),
  updateRolePermission
);
rolePermissionRoutes.delete(
  "/:id",
  authorize("deleteRolePermission"),
  deleteSingleRolePermission
);

module.exports = rolePermissionRoutes;