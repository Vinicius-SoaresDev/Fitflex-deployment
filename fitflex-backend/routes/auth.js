const express = require("express");
const router = express.Router();
const authController = require("../src/controllers/auth.controllers.js");

router.post("/signup", authController.signup);
router.post("/login", authController.login);

module.exports = router;
