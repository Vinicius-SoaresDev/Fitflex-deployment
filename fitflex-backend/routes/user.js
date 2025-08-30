const express = require("express");
const router = express.Router();
const userController = require("../src/controllers/userController");

// rota para salvar informações do usuário
router.post("/info", userController.saveUserInfo);

// rota para calcular TMB
router.post("/tmb", userController.calcularTMB);

module.exports = router;
