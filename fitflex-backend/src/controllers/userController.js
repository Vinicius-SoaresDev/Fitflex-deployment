const User = require("../../models/User");

// Converte "80kg", "1,80", "180cm" -> número
function parseNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  const onlyNum = String(value).replace(/[^\d.,-]/g, "").replace(",", ".");
  const parsed = parseFloat(onlyNum);
  return Number.isFinite(parsed) ? parsed : null;
}

exports.saveUserInfo = async (req, res) => {

  try {
    const { userId, peso, altura, metaPeso, idade, sexo, atividade } = req.body;

    if (!userId) {
      return res.status(400).json({ msg: "userId é obrigatório" });
    }

    const pesoNum = parseNumber(peso);
    const alturaNum = parseNumber(altura);
    const metaPesoNum = parseNumber(metaPeso);
    const idadeNum = parseNumber(idade);

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ msg: "Usuário não encontrado" });

    if (pesoNum !== null) user.peso = pesoNum;
    if (alturaNum !== null) user.altura = alturaNum;
    if (metaPesoNum !== null) user.metaPeso = metaPesoNum;
    if (idadeNum !== null) user.idade = idadeNum;
    if (sexo) user.sexo = sexo.toLowerCase();
    if (atividade) user.atividade = atividade.toLowerCase();

    await user.save();

    res.json({ msg: "✅ Informações salvas com sucesso!", user });
  } catch (err) {
    res.status(500).json({ msg: "Erro no servidor", error: err.message });
  }
};


exports.calcularTMB = async (req, res) => {
  try {
    const { userId } = req.body;
    if (!userId) return res.status(400).json({ msg: "userId é obrigatório" });

    const user = await User.findById(userId).lean();
    if (!user) return res.status(404).json({ msg: "Usuário não encontrado" });

    if (user.peso == null || user.altura == null || user.idade == null || !user.sexo) {
      return res.status(400).json({ msg: "Peso, altura, idade e sexo são obrigatórios" });
    }

    // Fórmula Mifflin-St Jeor (altura em cm)
    let tmb = (10 * user.peso) + (6.25 * user.altura) - (5 * user.idade);
    tmb += user.sexo === "masculino" ? 5 : -161;

    // Fator de atividade
    const fatorMap = { baixo: 1.2, medio: 1.55, alto: 1.725 };
    const fator = fatorMap[user.atividade || "baixo"] || 1.2;

    const gastoCalorico = Math.round(tmb * fator);

    return res.json({
      tmb: Math.round(tmb),
      gastoCalorico,
      atividade: user.atividade || "baixo",
    });
  } catch (err) {
    return res.status(500).json({ msg: "Erro no servidor", error: err.message });
  }
};
