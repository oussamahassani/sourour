const Document = require('../models/Document');

// 📌 Ajouter un document
exports.ajouterDocument = async (req, res) => {
  try {
    const { titre, type_document, chemin_fichier, id_utilisateur, id_entite, type_entite, description } = req.body;

    const newDocument = new Document({
      titre,
      type_document,
      chemin_fichier,
      id_utilisateur,
      id_entite,
      type_entite,
      description
    });

    await newDocument.save();
    res.status(201).json({ message: 'Document ajouté avec succès', document: newDocument });
  } catch (error) {
    console.error("Erreur lors de l'ajout du document :", error);
    res.status(500).json({ error: "Erreur serveur lors de la création du document" });
  }
};

// 📌 Lister tous les documents
exports.listerDocuments = async (req, res) => {
  try {
    const documents = await Document.find().populate('id_utilisateur', 'nom').populate('id_entite');
    res.status(200).json({ documents });
  } catch (error) {
    console.error("Erreur lors de la récupération des documents :", error);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des documents" });
  }
};

// 📌 Récupérer un document par ID
exports.getDocumentById = async (req, res) => {
  try {
    const { id } = req.params;
    const document = await Document.findById(id).populate('id_utilisateur', 'nom').populate('id_entite');

    if (!document) {
      return res.status(404).json({ error: "Document non trouvé" });
    }

    res.status(200).json({ document });
  } catch (error) {
    console.error("Erreur lors de la récupération du document :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// 📌 Modifier un document
exports.modifierDocument = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedDocument = await Document.findByIdAndUpdate(id, req.body, { new: true });

    if (!updatedDocument) {
      return res.status(404).json({ error: "Document non trouvé" });
    }

    res.status(200).json({ message: "Document mis à jour avec succès", document: updatedDocument });
  } catch (error) {
    console.error("Erreur lors de la mise à jour du document :", error);
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour du document" });
  }
};

// 📌 Supprimer un document
exports.supprimerDocument = async (req, res) => {
  try {
    const { id } = req.params;
    const document = await Document.findByIdAndDelete(id);

    if (!document) {
      return res.status(404).json({ error: "Document non trouvé" });
    }

    res.status(200).json({ message: "Document supprimé avec succès" });
  } catch (error) {
    console.error("Erreur lors de la suppression du document :", error);
    res.status(500).json({ error: "Erreur serveur lors de la suppression du document" });
  }
};
