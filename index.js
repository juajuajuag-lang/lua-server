
const express = require("express");
const fs = require("fs");
const path = require("path");

const app = express();

const PORT = process.env.PORT || 3000;

app.get("/", (req, res) => {
    res.send("Servidor funcionando correctamente.");
});

app.get("/script", (req, res) => {
    const scriptPath = path.join(
        __dirname,
        "scripts",
        "script.lua"
    );

    if (!fs.existsSync(scriptPath)) {
        return res.status(404).send("Script no encontrado.");
    }

    const script = fs.readFileSync(scriptPath, "utf8");

    res.type("text/plain").send(script);
});

app.listen(PORT, "0.0.0.0", () => {
    console.log("Servidor iniciado en el puerto " + PORT);
});
