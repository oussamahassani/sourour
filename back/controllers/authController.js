const User = require('../models/User');
const Role = require('../models/Role');

const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const {sendCompteCreationConfirmationEmailAdmin} = require('../utils/emiling')

// Inscription
exports.signup = async (req, res) => {
  const { nom, prenom, telephone, email, motDePasse, role } = req.body;

  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(409).json({ message: 'Cet email est déjà utilisé.' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(motDePasse, salt);

    const user = new User({
      nom,
      prenom,
      telephone,
      email,
      motDePasse: hashedPassword,
      role,
    });
    await user.save();
        const userAD =  await User.findOne({role:"admin"});
    
    const sendmail = await sendCompteCreationConfirmationEmailAdmin(userAD,user)
    const token = jwt.sign({ userId: user._id, role: user.role }, process.env.JWT_SECRET, {
      expiresIn: '1h',
    });

    res.status(201).json({ token, userId: user._id, role: user.role });
  } catch (err) {
    res.status(500).json({ message: 'Erreur lors de l\'inscription', error: err.message });
  }
};

// Connexion
exports.login = async (req, res) => {
  const { email, motDePasse } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Email ou mot de passe incorrect.' });
    }
    if (user.status && user.role !="admin") {
      return res.status(400).json({ message: 'compte nom encore valide.' });
    }

    const isMatch = await bcrypt.compare(motDePasse, user.motDePasse);
    if (!isMatch) {
      return res.status(400).json({ message: 'Email ou mot de passe incorrect.' });
    }
   
    const role = await Role.findOne({ name: user.role })
  .populate({
    path: 'rolePermission',
    populate: {
      path: 'permission'
    }
  });

  let permissionNames = []
if (role) {
  permissionNames =  role.rolePermission.map(
    (rp) => rp.permission.name
  );
}


    const token = jwt.sign({ userId: user._id, role: user.role,permissions: permissionNames }, process.env.JWT_SECRET, {
      expiresIn: '1h',
    });

    res.status(200).json({ token, userId: user._id, role: user.role , username:user.nom });
  } catch (err) {
    res.status(500).json({ message: 'Erreur lors de la connexion', error: err.message });
  }
};