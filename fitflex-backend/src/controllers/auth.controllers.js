const User = require("../../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// SIGNUP
exports.signup = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Validações
    if (!name || name.length < 3) {
      return res.status(400).json({ msg: "O nome deve ter pelo menos 3 caracteres." });
    }
    if (!email || !email.includes("@")) {
      return res.status(400).json({ msg: "Digite um email válido." });
    }
    if (!password || password.length < 8) {
      return res.status(400).json({ msg: "A senha deve ter pelo menos 8 caracteres." });
    }

    // Verifica se já existe usuário
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ msg: "Email já está em uso." });
    }

    // Criptografa senha
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Cria usuário
    const newUser = new User({ name, email, password: hashedPassword });
    await newUser.save();

    // Gera token JWT
    const token = jwt.sign({ id: newUser._id }, process.env.JWT_SECRET, {
      expiresIn: "1d",
    });

    return res.status(201).json({
      msg: "Usuário registrado com sucesso!",
      token,
      userId: newUser._id.toString(), 
      user: { id: newUser._id, name: newUser.name, email: newUser.email }
    });
  } catch (err) {
    console.error("❌ Erro no signup:", err);
    return res.status(500).json({ msg: "Erro no servidor", error: err.message });
  }
};


// LOGIN 
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ msg: "Preencha email e senha." });
    }

    // Busca usuário
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ msg: "Credenciais inválidas." });
    }

    // Confere senha
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Credenciais inválidas." });
    }

    // Gera token
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: "1d",
    });

    return res.json({
      msg: "Login realizado com sucesso!",
      userId: user._id.toString(),
      token,
      user: { id: user._id, name: user.name, email: user.email },
    });
  } catch (err) {
    console.error("❌ Erro no login:", err);
    return res.status(500).json({ msg: "Erro no servidor.", error: err.message });
  }
};
