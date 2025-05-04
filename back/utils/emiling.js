const nodemailer = require('nodemailer');
let transporter = nodemailer.createTransport({
    host: "sandbox.smtp.mailtrap.io",
    port: 2525,
    auth: {
      user: "c53cf314d88bd6",
      pass: "c6c7a69a4e24fa"
    }
  });
  const sendCompteCreationConfirmationEmail = (customerEmail, user , pass) => {
    const mailOptions = {
      from: 'system@gmail.com',
      to: customerEmail,
      subject: 'Compte Creation Confirmation',
      html: `<p>Dear ${user.nom},</p>
             <p>Your compte is created in this app :  ( ${process.env.UrlFontEnd})</p>
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

  const sendCompteCreationActivation= (customerEmail, user ) => {
    const mailOptions = {
      from: 'system@gmail.com',
      to: customerEmail,
      subject: 'Compte Creation Activation',
      html: `<p>Dear ${user.nom},</p>
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
  };
  