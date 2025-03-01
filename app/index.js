const https = require('https');
const fs = require('fs');
const express = require('express');
const app = express();
const httpsPort = process.env.HTTPS_PORT || 443;

// Read SECRET_WORD from environment variable
global.MY_SECRET_WORD = 'default-secret';

// Load the self-signed certificate and private key
const options = {
  key: fs.readFileSync('/app/certs/private.key'),
  cert: fs.readFileSync('/app/certs/certificate.crt')
};

// Create an HTTPS server
https.createServer(options, app).listen(httpsPort, () => {
  console.log(`Secret Word as process ENV: ${process.env.SECRET_WORD}`);
  console.log(`Secret Word: ${global.MY_SECRET_WORD}`);
  global.MY_SECRET_WORD = process.env.SECRET_WORD
  console.log(`Secret Word after update: ${global.MY_SECRET_WORD}`);
  console.log(`HTTPS server running on port ${httpsPort}`);
});

app.get('/', (req, res) => {
  res.send(`SECRET_WORD: ${global.MY_SECRET_WORD}`);
});

app.get('/docker', (req, res) => {
  // Check if the .dockerenv file exists
  const isDocker = fs.existsSync('/.dockerenv');

  if (isDocker) {
    res.send('Docker check passed! Running inside a Docker container.');
  } else {
    res.send('Docker check failed! Not running inside a Docker container.');
  }
});

app.get('/secret_word', (req, res) => {
  res.send(`SECRET_WORD: ${global.MY_SECRET_WORD}`);
});

app.get('/loadbalanced', (req, res) => {
  // Check for Load Balancer headers
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

