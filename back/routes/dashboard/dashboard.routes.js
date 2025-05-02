const express = require("express");
const { getDashboardData } = require("./dashboard.controllers");
const authorize = require("../../utils/autorize"); // authentication middleware

const dashboardRoutes = express.Router();

dashboardRoutes.get("/", authorize("viewDashboard"), getDashboardData);

module.exports = dashboardRoutes;
