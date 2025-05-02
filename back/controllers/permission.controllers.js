const getPagination = require("../utils/pagination"); // authentication middleware
const Permission  = require("../models/Permission")
const getAllPermission = async (req, res) => {
    try {
      if (req.query.query === "all") {
        const allPermissions = await Permission.find().sort({ _id: 1 });
        return res.json(allPermissions);
      } else {
        const { skip, limit } = getPagination(req.query);
  
        const paginatedPermissions = await Permission.find()
          .sort({ _id: 1 })
          .skip(Number(skip))
          .limit(Number(limit));
  
        return res.json(paginatedPermissions);
      }
    } catch (error) {
      res.status(400).json({ message: error.message });
      console.log(error.message);
    }
  };
  module.exports = {
    getAllPermission,
  };