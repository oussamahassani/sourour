const Facture = require('../models/Facture');

// 📌 Ajouter une facture
exports.ajouterFacture = async (req, res) => {
  try {
    const { numero_facture, idACH, idV, idF, idP, idCL, idU, prixHTV, TVA, prixTTC, type, date_echeance, statut, id_document } = req.body;

    const newFacture = new Facture({
      numero_facture,
      idACH,
      idV,
      idF,
      idP,
      idCL,
      idU,
      prixHTV,
      TVA,
      prixTTC,
      type,
      date_echeance,
      statut,
      id_document
    });

    await newFacture.save();
    res.status(201).json({ message: 'Facture ajoutée avec succès', facture: newFacture });
  } catch (error) {
    console.error("Erreur lors de l'ajout de la facture :", error);
    res.status(500).json({ error: "Erreur serveur lors de l'ajout de la facture" });
  }
};

// 📌 Lister toutes les factures
exports.listerFactures = async (req, res) => {
  try {
    const factures = await Facture.find()
    for (let fact of factures) {
    if (fact.idACH) {
        await fact.populate('idACH');
    }
  }
  for (let fact of factures) {
    if (fact.idV) {
        await fact.populate('idV');
    }
  }
      for (let fact of factures) {
    if (fact.idF) {
        await fact.populate('idF','nomF');
    }
  }
  for (let fact of factures) {
    if (fact.idP) {
        await fact.populate('idP','nom');
    }
  }
      for (let fact of factures) {
    if (fact.idCL) {
        await fact.populate('idCL','nom');
    }
  }
      for (let fact of factures) {
    if (fact.idU) {
        await fact.populate('idU','nom');
    }
  }
      
   

    res.status(200).json( factures );
  } catch (error) {
    console.error("Erreur lors de la récupération des factures :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des factures" });
  }
};

// 📌 Récupérer une facture par ID
exports.getFactureById = async (req, res) => {
  try {
    const { id } = req.params;
    const facture = await Facture.findById(id)
   
  
      
   

    if (!facture) {
      return res.status(404).json({ error: "Facture non trouvée" });
    }
  if (facture.idACH) {
        await facture.populate('idACH', 'nom');
    }
        if (facture.idV) {
        await facture.populate('idV', 'nom');
    }
        if (facture.idF) {
        await facture.populate('idF', 'nomF');
    }
    
          if (facture.idCL) {
        await facture.populate('idCL', 'nom');
    }
    res.status(200).json({ facture });
  } catch (error) {
    console.error("Erreur lors de la récupération de la facture :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// 📌 Modifier une facture
exports.modifierFacture = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedFacture = await Facture.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedFacture) {
      return res.status(404).json({ error: "Facture non trouvée" });
    }

    res.status(200).json({ message: "Facture mise à jour avec succès", facture: updatedFacture });
  } catch (error) {
    console.error("Erreur lors de la mise à jour de la facture :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour de la facture" });
  }
};

// 📌 Supprimer une facture
exports.supprimerFacture = async (req, res) => {
  try {
    const { id } = req.params;
    const facture = await Facture.findByIdAndDelete(id);

    if (!facture) {
      return res.status(404).json({ error: "Facture non trouvée" });
    }

    res.status(200).json({ message: "Facture supprimée avec succès" });
  } catch (error) {
    console.error("Erreur lors de la suppression de la facture :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression de la facture" });
  }
};
