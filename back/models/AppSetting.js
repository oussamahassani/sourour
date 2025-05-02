const mongoose = require('mongoose');

const appSettingSchema = new mongoose.Schema({
    company_name: String,
    tag_line: String,
    address: String,
    phone: String,
    email: String,
    website: String,
    footer: String
});

module.exports = mongoose.model('AppSetting', appSettingSchema);
