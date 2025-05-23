const nodemailer = require('nodemailer');
let transporter = nodemailer.createTransport({
    host: "sandbox.smtp.mailtrap.io",
    port: 2525,
    auth: {
      user: "c53cf314d88bd6",
      pass: "c6c7a69a4e24fa"
    }
  });

  const sendNotificationAdminClientCreation = async (admin , client) => {
    const mailOptions = {
      from: 'system@gmail.com',
      to: admin.email,
      subject: 'new Validation custommer',
      html: `<p>Dear ${admin.nom},</p>
             <p>Your have new custommer is created in this app :  (<a href= ${process.env.UrlFontEnd}/customer/${client._id}>view site </a>)</p>
            `
    };
  
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.log('Error sending email:', error);
      } else {
        console.log('Email sent:', info.response);
      }
      return true
    });
  }
    const sendCompteCreationConfirmationEmailUser = async (customerEmail, user ) => {
    const mailOptions = {
      from: 'system@gmail.com',
      to: customerEmail,
      subject: 'Compte Creation Confirmation User',
      html: `<p>Dear ${user.nom},</p>
             <p>Your compte is created and is active Now )</p>
             `
    };
  
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.log('Error sending email:', error);
      } else {
        console.log('Email sent:', info.response);
      }
      return true
    });
  };
  const sendCompteCreationConfirmationEmail = async (customerEmail, user , pass) => {
    const mailOptions = {
      from: 'system@gmail.com',
      to: customerEmail,
      subject: 'Compte Creation Confirmation',
      html: `<p>Dear ${user.nom},</p>
             <p>Your compte is created in this app :  (<a href= ${process.env.UrlFontEnd}>web site </a>)</p>
             <p>your password is  ${pass} has been confirmed.</p>`
    };
  
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.log('Error sending email:', error);
      } else {
        console.log('Email sent:', info.response);
      }
      return true
    });
  };

 const  sendCompteCreationConfirmationEmailAdmin = async (admin , user)=> {
        const mailOptions = {
      from: 'system@gmail.com',
      to: admin.email,
      subject: 'Admin  Activation Compte',
      html: `<p>Dear ${admin.nom},</p>
      <p>le compte de ${user.email} : ${user.nom}  ${user.prenom} is  stil waiting to Active )</p>
                  <p>to activate this  compte iin this app :  (<a href= ${process.env.UrlFontEnd}/hr/adminstaffs/${user._id}/update>activate  Compte </a>)</p>
            `
    };
  
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.log('Error sending email:', error);

      } else {
        console.log('Email sent:', info.response);
      }
      return true
    });
  }
  const sendCompteCreationActivation= async (customerEmail, user,updatedClient ) => {
    const mailOptions = {
      from: 'system@gmail.com',
      to: customerEmail,
      subject: 'Compte Creation Activation',
      html: `<p>Dear ${user.nom},</p>
      <p>le compte de ${updatedClient.email} : ${updatedClient.nom}  ${updatedClient.prenom} is Active now )</p>
             <p>Your compte is Active now )</p>
            `
    };
  
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.log('Error sending email:', error);

      } else {
        console.log('Email sent:', info.response);
      }
      return true
    });
  };

  module.exports = {
    sendCompteCreationConfirmationEmail,
    sendCompteCreationActivation,
    sendCompteCreationConfirmationEmailUser,
    sendCompteCreationConfirmationEmailAdmin,
    sendNotificationAdminClientCreation
  };
  