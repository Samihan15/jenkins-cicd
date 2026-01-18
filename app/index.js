const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("🚀 Production CI/CD Node App Running");
});

app.listen(3000, "0.0.0.0", () => {
  console.log("Server running");
});
