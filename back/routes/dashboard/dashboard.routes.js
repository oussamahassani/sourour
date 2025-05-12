const express = require("express");
const { getDashboardData,getDashboardMobileData } = require("./dashboard.controllers");
const authorize = require("../../utils/autorize"); // authentication middleware

const dashboardRoutes = express.Router();

dashboardRoutes.get("/", authorize("viewDashboard"), getDashboardData);
dashboardRoutes.get("/mobile", getDashboardMobileData);

module.exports = dashboardRoutes;
