
const Role = require('../models/Role');
const getPagination = require("../utils/pagination"); // authentication middleware

const createSingleRole = async (req, res) => {
    try {
      if (req.query.query === "deletemany") {
        const deletedRole = await Role.deleteMany({
            _id: { $in: req.body } 
        });
        res.json(deletedRole);
      } else if (req.query.query === "createmany") {
        console.log(
          req.body.map((role) => {
            return {
              name: role.name,
            };
          })
        );
        console.log(req.body);
        const createdRole = await Role.insertMany(req.body, { ordered: false });
        res.status(200).json(createdRole);
      } else {
        const createdRole = await Role.create({ name: req.body.name })
        res.status(200).json(createdRole);
      }
    } catch (error) {
      res.status(400).json(error.message);
      console.log(error.message);
    }
  };
  
  const getAllRole = async (req, res) => {
    if (req.query.query === "all") {
      const allRole = await Role.find()
      res.json(allRole);
    } else if (req.query.status === "false") {
      try {
        const { skip, limit } = getPagination(req.query);
        const allRole =await Role.find({ status: false })
        .sort({ _id: 1 }) // "id: 'asc'" en Prisma, correspond à "_id: 1" en MongoDB
        .skip(Number(skip))
        .limit(Number(limit))
        .populate({
          path: 'rolePermission',
          populate: {
            path: 'permission', // Ce champ doit exister comme une ref dans rolePermission
          },
        });
        res.json(allRole);
      } catch (error) {
        res.status(400).json(error.message);
        console.log(error.message);
      }
    } else {
      const { skip, limit } = getPagination(req.query);
      try {
        const allRole = await Role.find({ status: true })
        .sort({ _id: 1 }) // "id: 'asc'" → _id en MongoDB
        .skip(Number(skip))
        .limit(Number(limit))
        .populate({
          path: 'rolePermission',
          populate: {
            path: 'permission', // assure-toi que ce champ existe dans le schéma RolePermission
          },
        });
      
        res.json(allRole);
      } catch (error) {
        res.status(400).json(error.message);
        console.log(error.message);
      }
    }
  };
  
  const getSingleRole = async (req, res) => {
    try {
      const roleId = req.params.id;
  
      const singleRole = await Role.findById(roleId).populate({
        path: 'rolePermission',
        populate: {
          path: 'permission'
        }
      });
  
      if (!singleRole) return res.status(404).json({ message: "Role not found" });
  
      res.json(singleRole);
    } catch (error) {
      res.status(400).json({ message: error.message });
      console.log(error.message);
    }
  };
  const updateSingleRole = async (req, res) => {
    try {
      const roleId = req.params.id;
  
      const updatedRole = await Role.findByIdAndUpdate(
        roleId,
        { name: req.body.name },
        { new: true }
      );
  
      if (!updatedRole) return res.status(404).json({ message: "Role not found" });
  
      res.json(updatedRole);
    } catch (error) {
      res.status(400).json({ message: error.message });
      console.log(error.message);
    }
  };
  const deleteSingleRole = async (req, res) => {
    try {
      const roleId = req.params.id;
  
      const deletedRole = await Role.findByIdAndUpdate(
        roleId,
        { status: req.body.status },
        { new: true }
      );
  
      if (!deletedRole) return res.status(404).json({ message: "Role not found" });
  
      res.json(deletedRole);
    } catch (error) {
      res.status(400).json({ message: error.message });
      console.log(error.message);
    }
  };
  
  
  module.exports = {
    createSingleRole,
    getAllRole,
    getSingleRole,
    updateSingleRole,
    deleteSingleRole,
  };