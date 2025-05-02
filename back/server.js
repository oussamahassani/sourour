require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const authRoutes = require('./routes/authRoutes');
const role = require('./routes/roleRoutes');
const rolePermission = require('./routes/rolePermission');
const AdminRouter = require('./routes/adminRoutes');
const UserRouter = require('./routes/rhRoutes');
const ClientRoute = require('./routes/clientRoute');
const fournisseurtRoute = require('./routes/fournisseursRoutes');
const produittRoute = require('./routes/articleRoutes');

const paymentPurchaseInvoiceRoutes = require("./routes/purchase/paymentPurchaseInvoice/paymentPurchaseInvoice.routes");
const paymentSaleInvoiceRoutes = require("./routes/sale/paymentSaleInvoice/paymentSaleInvoice.routes");
const returnSaleInvoiceRoutes = require("./routes/sale/returnSaleInvoice/returnSaleInvoice.routes");
const purchaseInvoiceRoutes = require("./routes/purchase/purchaseInvoice/purchaseInvoice.routes");
const returnPurchaseInvoiceRoutes = require("./routes/purchase/returnPurchaseInvoice/returnPurchaseInvoice.routes");
const saleInvoiceRoutes = require("./routes/sale/saleInvoice/saleInvoice.routes");
//const transactionRoutes = require("./routes/accounting/transaction/transaction.routes");

const dashboardRoutes = require("./routes/dashboard/dashboard.routes");

const initPermissions = require("./initPermission");

const cors = require('cors');

const app = express();
app.use(express.json()); // Middleware pour parser le JSON
app.use(cors());

const MONGO_URI = process.env.MONGO_URI;
const PORT = process.env.PORT || 3000;

// Fonction pour se connecter à MongoDB avec gestion des erreurs

const connectDB = async () => {
    try {
        console.log(process.env.MONGO_URI)
        mongoose.connect("mongodb://127.0.0.1:27017/your-db-name")
            .then(res => {
                console.log('✅ Connexion à MongoDB réussie')
                //initPermissions(); // initialise les permissions une seule fois


            })
            .catch(err => console.log(err))

    } catch (err) {
        console.error('❌ Erreur de connexion à MongoDB:', err.message);
        setTimeout(connectDB, 3000); // Réessaie après 5 secondes
    }
};

// Lancer la connexion à la base de données
connectDB();

// Routes d'authentification
app.use('/api/auth', authRoutes);
app.use('/role', role);
app.use('/role-permission', rolePermission);
app.use('/admin', AdminRouter);
app.use('/user', UserRouter);
app.use('/', ClientRoute);
app.use('/', fournisseurtRoute);
app.use('/product', produittRoute);
app.use("/payment-purchase-invoice", paymentPurchaseInvoiceRoutes);
app.use("/payment-sale-invoice", paymentSaleInvoiceRoutes);
app.use("/return-sale-invoice", returnSaleInvoiceRoutes);
app.use("/sale-invoice", saleInvoiceRoutes);

app.use("/purchase-invoice", purchaseInvoiceRoutes);
app.use("/return-purchase-invoice", returnPurchaseInvoiceRoutes);
//app.use("/account", accountRoutes);
//app.use("/setting", settingRoutes);
//app.use("/transaction", transactionRoutes);
app.use("/dashboard", dashboardRoutes);

// Middleware de gestion des erreurs globales
app.use((err, req, res, next) => {
    console.error('❌ Erreur détectée:', err.stack);
    res.status(500).json({ message: 'Erreur interne du serveur' });
});
app.get('/', (req, res) => {
    res.send('CORS-enabled for all origins!');
});
// Démarrer le serveur
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Serveur démarré sur le port ${PORT}`);
});
