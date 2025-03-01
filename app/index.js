const fs = require('fs');
const express = require('express');
const app = express();
const httpPort = process.env.HTTP_PORT || 80;

// Global Variable to hold the secret word
global.MY_SECRET_WORD = 'default-secret';

app.listen(httpPort, () => {
  console.log(`Secret Word passed as ENV: ${process.env.SECRET_WORD}`);
  global.MY_SECRET_WORD = process.env.SECRET_WORD
  console.log(`App listening at http://localhost:${httpPort}`);
});

// Define a BASE URL of the application
app.get('/', (req, res) => {
  res.send(`SECRET_WORD: ${global.MY_SECRET_WORD}`);
});

// Define a route to check if the application is running inside a Docker container
app.get('/docker', (req, res) => {
  const isDocker = fs.existsSync('/.dockerenv');
  if (isDocker) {
    res.send('Docker check passed! Running inside a Docker container.');
  } else {
    res.send('Docker check failed! Not running inside a Docker container.');
  }
});

// Define a route to check if secret_word path is accessible
app.get('/secret_word', (req, res) => {
  res.send(`SECRET_WORD: ${global.MY_SECRET_WORD}`);
});

// Define a route to check if the application is running behind a Load Balancer
app.get('/loadbalanced', (req, res) => {
  const hasLoadBalancerHeaders =
    req.headers['x-forwarded-for'] ||
    req.headers['x-forwarded-proto'] ||
    req.headers['x-forwarded-port'];

  if (hasLoadBalancerHeaders) {
    res.send('Load Balancer check passed! Running behind a Load Balancer.');
  } else {
    res.send('Load Balancer check failed! Not running behind a Load Balancer.');
  }
});

// Define a route to validate TLS
app.get('/tls', (req, res) => {
  if (req.secure) {
    res.send('TLS check passed!');
  } else {
    res.status(400).send('TLS check failed: Request was not made over HTTPS.');
  }
});