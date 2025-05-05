const Client = require('../models/Client');
const User = require('../models/User');
// 📌 Ajouter un client
const {sendCompteCreationActivation,sendNotificationAdminClientCreation} = require('../utils/emiling')

exports.ajouterClient = async (req, res) => {
 /* if(req.query.query === "createmany"){
    try {
      // Step 1: Get all existing phone numbers from the DB
      const existingCustomers = await Client.find({}, 'email').lean();
      const existingPhones = new Set(existingCustomers.map(c => c.email));
  
      // Step 2: Filter incoming customer data
      let newCustomers = req.body.filter(customer => !existingPhones.has(customer.email));
      console.log(newCustomers)
       newCustomers = newCustomers.filter(item => item.cin && item.email);

      // Step 3: Insert only new customers
      if (newCustomers.length > 0) {
        const customersToInsert = newCustomers.map(customer => ({
          ...customer,
          validation_admin : Boolean(customer.validation_admin),
          createdAt: new Date(),
          updatedAt: new Date(),
        }));
        // Step 4: Insert new customers into the database
        let insertedCount = 0;

        for (const customer of customersToInsert) {
          try {
          const  {nom,prenom,telephone,email} = customer;
            const nouvelUtilisateur = new User({ nom, prenom, telephone, email, motDePasse:"12346", role:"Utilisateur" });
            const user = await nouvelUtilisateur.save();
            const ID= user._id;
            await Client.create({...customer , commercial_assigne:ID}); // ou new Client(customer).save()
            insertedCount++;
          } catch (err) {
            if (err.code === 11000) {
              console.warn(`Duplicate skipped for phone: ${customer.email}`);
            } else {
              console.error(`Error inserting customer:`, err);
            }
          }
        }

       return  res.json({ insertedCount: insertedCount });
      } else {
       return  res.json({ message: 'No new customers to insert.' });
      }
    } catch (error) {
      console.error(error);
      return  res.status(500).json({ error: error.message });
    }
  }*/
  try {
    const {
      nom, prenom, email, telephone, adresse,
      plafond_credit, validation_admin, entreprise,
      matricule, cin, commercial_assigne
    } = req.body;

    // 👇 ID à utiliser pour une autre collection
   // const = User.findById(commercial_assigne);
   // const commercial_assignes = ;

    const newClient = new Client({
      nom,
      prenom,
      email,
      telephone,
      adresse,
      plafond_credit,
      validation_admin,
      entreprise,
      matricule,
      cin,
      commercial_assigne:commercial_assigne
    });

    await newClient.save();
    const userAD =  await User.findOne({role:"admin"});

    await sendNotificationAdminClientCreation(userAD,newClient)

    if(validation_admin){
      const user =  await User.findById(commercial_assigne);
      await sendCompteCreationActivation(user.email,user)
    }
    res.status(201).json({ message: 'Client ajouté avec succès', client: newClient });
  } catch (error) {
    console.error("Erreur lors de l'ajout du client :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout du client" });
  }
};

// 📌 Lister tous les clients
exports.listerClients = async (req, res) => {
  try {
    const clients = await Client.find().populate('commercial_assigne', 'nom prenom');
    res.status(200).json({ clients });
  } catch (error) {
    console.error("Erreur lors de la récupération des clients :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des clients" });
  }
};

// 📌 Récupérer un client par ID
exports.getClientById = async (req, res) => {
  try {
    const { id } = req.params;
    const client = await Client.findById(id).populate('commercial_assigne', 'nom prenom');

    if (!client) {
      return res.status(404).json({ error: "Client non trouvé" });
    }

    res.status(200).json( client );
  } catch (error) {
    console.error("Erreur lors de la récupération du client :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// 📌 Modifier un client
exports.modifierClient = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedClient = await Client.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedClient) {
      return res.status(404).json({ error: "Client non trouvé" });
    }
    if(updatedClient && updatedClient.validation_admin){
      const user =  await User.findById(updatedClient.commercial_assigne);
      await sendCompteCreationActivation(user.email,user , updatedClient)
    }
    res.status(200).json({ message: "Client mis à jour avec succès", client: updatedClient });
  } catch (error) {
    console.error("Erreur lors de la mise à jour du client :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour du client" });
  }
};

// 📌 Supprimer un client
exports.supprimerClient = async (req, res) => {
  try {
    const { id } = req.params;
    const client = await Client.findByIdAndDelete(id);

    if (!client) {
      return res.status(404).json({ error: "Client non trouvé" });
    }

    res.status(200).json({ message: "Client supprimé avec succès" });
  } catch (error) {
    console.error("Erreur lors de la suppression du client :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression du client" });
  }
};
