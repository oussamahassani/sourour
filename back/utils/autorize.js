const { expressjwt: jwt } = require("express-jwt");
const secret = "sisir_chikon_ho";

// Middleware d'autorisation basé sur permission unique
function authorize(requiredPermission) {
  return [
    // Authentifie le token JWT
    jwt({ secret, algorithms: ["HS256"] }),

    // Vérifie la permission
    (req, res, next) => {
      const userPermissions = req.auth?.permissions || [];

      if (
        requiredPermission &&
        !userPermissions.includes(requiredPermission)
      ) {
        return res.status(403).json({ message: "Forbidden: insufficient permission" });
      }

      next();
    },
  ];
}

module.exports = authorize;
