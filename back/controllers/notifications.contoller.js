const Notification = require('../models/Notifications'); // Assurez-vous que ce chemin est correct

// Ajouter une notification
exports.ajouterNotification = async (req, res) => {
  try {
    const { idU, message, statut, url_redirection, type_notification, priorité, date_expiration } = req.body;
    const notification = new Notification({
      idU,
      message,
      statut,
      url_redirection,
      type_notification,
      priorité,
      date_expiration
    });

    await notification.save();
    res.status(201).json({ message: 'Notification ajoutée avec succès', notification });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur lors de l\'ajout de la notification', error });
  }
};

// Récupérer toutes les notifications
exports.getAllNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find();
    res.status(200).json(notifications);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur lors de la récupération des notifications', error });
  }
};

// Mettre à jour le statut d'une notification
exports.updateNotificationStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { statut } = req.body;

    const updatedNotification = await Notification.findByIdAndUpdate(id, { statut }, { new: true });

    if (!updatedNotification) {
      return res.status(404).json({ message: 'Notification non trouvée' });
    }

    res.status(200).json({ message: 'Statut de la notification mis à jour', updatedNotification });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur lors de la mise à jour du statut', error });
  }
};

// Supprimer une notification
exports.deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedNotification = await Notification.findByIdAndDelete(id);

    if (!deletedNotification) {
      return res.status(404).json({ message: 'Notification non trouvée' });
    }

    res.status(200).json({ message: 'Notification supprimée avec succès' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur lors de la suppression de la notification', error });
  }
};
