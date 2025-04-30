const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
});

const User = mongoose.model('User', UserSchema);

const getUserByEmail = async (email) => {
    return await User.findOne({ email });
};

module.exports = { User, getUserByEmail };
