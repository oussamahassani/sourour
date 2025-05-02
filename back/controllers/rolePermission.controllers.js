const RolePermission = require("../models/RolePermission");
const Role = require('../models/Role');

const getPagination  = require("../utils/pagination");

const createRolePermission = async (req, res) => {
  try {
    if (req.query.query === "deletemany") {
      const deleted = await RolePermission.deleteMany({
        _id: { $in: req.body },
      });
      return res.json(deleted);
    }

    // Format incoming data
    const data = req.body.permission_id.map((permission) => ({
      role: req.body.role_id,
      permission,
    }));

    const created = await RolePermission.insertMany(data, { ordered: false });
    const insertedIds = created.map((rp) => rp._id);

// Mets à jour le Role pour lier les RolePermission
await Role.findByIdAndUpdate(req.body.role_id, {
  $addToSet: { rolePermission: { $each: insertedIds } }
});
    res.status(200).json(created);
  } catch (error) {
    res.status(400).json({ message: error.message });
    console.log(error.message);
  }
};

const getAllRolePermission = async (req, res) => {
  try {
    const query = RolePermission.find()
      .populate("role_id")
      .populate("permission_id")
      .sort({ _id: 1 });

    if (req.query.query !== "all") {
      const { skip, limit } = getPagination(req.query);
      query.skip(Number(skip)).limit(Number(limit));
    }

    const result = await query.exec();
    res.json(result);
  } catch (error) {
    res.status(400).json({ message: error.message });
    console.log(error.message);
  }
};

const getSingleRolePermission = async (req, res) => {
  try {
    const permission = await RolePermission.findById(req.params.id);
    res.json(permission);
  } catch (error) {
    res.status(400).json({ message: error.message });
    console.log(error.message);
  }
};

const updateRolePermission = async (req, res) => {
  try {
    const data = req.body.permission_id.map((permission_id) => ({
      role_id: req.body.role_id,
      permission_id,
    }));

    const updated = await RolePermission.insertMany(data, { ordered: false });
    res.json(updated);
  } catch (error) {
    res.status(400).json({ message: error.message });
    console.log(error.message);
  }
};

const deleteSingleRolePermission = async (req, res) => {
  try {
    const deleted = await RolePermission.findByIdAndDelete(req.params.id);
    res.status(200).json(deleted);
  } catch (error) {
    res.status(400).json({ message: error.message });
    console.log(error.message);
  }
};

module.exports = {
  createRolePermission,
  getAllRolePermission,
  getSingleRolePermission,
  updateRolePermission,
  deleteSingleRolePermission,
};
