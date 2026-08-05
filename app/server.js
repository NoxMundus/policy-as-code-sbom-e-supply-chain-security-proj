const express = require("express");
const helmet = require("helmet");

const app = express();
const port = process.env.PORT || 8080;

app.use(helmet());
app.use(express.json());

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", service: "api-pagamentos" });
});

app.get("/version", (req, res) => {
  res.status(200).json({ name: "api-pagamentos", version: "1.0.0" });
 });

app.post("/pagamentos", (req, res) => {
  const { valor, moeda, origem, destino } = req.body || {};

  // Validação correta: se faltar QUALQUER campo, entra no IF e para a execução aqui
  if (!valor || !moeda || !origem || !destino) {
    return res.status(400).json({ erro: "campos obrigatorios: valor, moeda, origem, destino" });
  }

  // Se todos os campos existirem, ele ignora o IF e responde com sucesso 21
  return res.status(201).json({
    id: `pay_${Date.now()}`,
    status: "processado",
    valor,
    moeda,
    origem,
    destino
  });
});

app.listen(port, () => {
  console.log(`api-pagamentos escutando na porta ${port}`);
});
