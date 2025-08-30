const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
    },
    password: {
      type: String,
      required: true,
    },
    peso: {
      type: Number,
      default: null,
    },
    altura: {
      type: Number,
      default: null,
    },
    metaPeso: {
      type: Number,
      default: null,
    },
    idade: { 
      type: Number,
      default: null,
    },
    sexo: { 
      type: String, 
      enum: ["masculino", "feminino"],
      default: null,
    },
    atividade: {
      type: String, 
      enum: ["baixo", "medio", "alto"],
      default: "baixo",
    }
  },
  { timestamps: true } // cria createdAt e updatedAt automaticamente
);

module.exports = mongoose.model('User', UserSchema);
