require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const authRoutes = require('./routes/authRoutes');
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
            .then(res => console.log('✅ Connexion à MongoDB réussie'))
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
