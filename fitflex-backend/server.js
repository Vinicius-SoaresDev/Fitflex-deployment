const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const app = express();

// Middlewares globais
app.use(cors());
app.use(express.json());

// Rotas
const authRoutes = require("./routes/auth");
const userRoutes = require("./routes/user");

// prefixos de API
app.use("/api/auth", authRoutes);
app.use("/api/user", userRoutes);

// Conexão MongoDB
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log("✅ MongoDB conectado");

    // Start do servidor só depois da conexão
    const PORT = process.env.PORT || 5000;
    app.get("/", (req, res) => {
      res.send("🚀 API Fitflex rodando com sucesso!");
    });
    app.listen(PORT, () => console.log(`🚀 Servidor rodando na porta ${PORT}`));
  })
  .catch((err) => console.error("❌ Erro MongoDB:", err));
