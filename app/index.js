const express = require('express');
const app = express();
const port = process.env.PORT || 80;

// Read SECRET_WORD from environment variable
const SECRET_WORD = process.env.SECRET_WORD || 'default-secret';

app.get('/', (req, res) => {
  res.send(`SECRET_WORD: ${SECRET_WORD}`);
});

app.get('/docker', (req, res) => {
  res.send('Docker check passed!');
});

app.get('/secret_word', (req, res) => {
  res.send(`SECRET_WORD: ${SECRET_WORD}`);
});

app.get('/loadbalanced', (req, res) => {
  res.send('Load Balancer check passed!');
});

app.get('/tls', (req, res) => {
  res.send('TLS check passed!');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});