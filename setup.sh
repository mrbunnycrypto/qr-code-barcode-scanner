#!/bin/bash

# Update and install Node.js and npm
echo "Installing Node.js..."
pkg update -y
pkg install -y nodejs

# Create project directory
echo "Creating project directory..."
mkdir qr-code-barcode-scanner
cd qr-code-barcode-scanner

# Initialize Node.js project
echo "Initializing Node.js project..."
npm init -y

# Install required dependencies
echo "Installing dependencies..."
npm install express qrcode jsbarcode canvas

# Create the public directory
echo "Creating public directory..."
mkdir public

# Copy the sample image (Download.png) into the public folder
echo "Please move your image to /storage/emulated/0/Download/Download.png and press any key to continue..."
read -n 1 -s

cp /storage/emulated/0/Download/Download.png ./public/Download.png

# Create the server.js file
echo "Creating server.js file..."

cat > server.js <<EOL
const express = require('express');
const QRCode = require('qrcode');
const JsBarcode = require('jsbarcode');
const canvas = require('canvas');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;

// Serve static files from the 'public' folder
app.use(express.static('public'));

// Home route: Display the PNG image and links to generate QR Code & Barcode
app.get('/', (req, res) => {
  res.send(\`
    <h1>Welcome to QR Code and Barcode Generator</h1>
    <p>Here is a sample PNG image:</p>
    <img src="/Download.png" alt="Download Image" />
    <p><a href="/generate-qrcode?url=https://example.com">Generate QR Code</a></p>
    <p><a href="/generate-barcode?text=987654321">Generate Barcode</a></p>
  \`);
});

// Route to generate QR code
app.get('/generate-qrcode', (req, res) => {
  const url = req.query.url || 'https://your-website.com';
  QRCode.toDataURL(url, (err, url) => {
    res.send(\`
      <h1>QR Code Generator</h1>
      <img src="\${url}" alt="QR Code" />
      <p><a href="\${url}" target="_blank">Go to Website</a></p>
    \`);
  });
});

// Route to generate Barcode
app.get('/generate-barcode', (req, res) => {
  const text = req.query.text || '123456789';
  const barcodePath = path.join(__dirname, 'public', 'barcode.png');
  const canvasElement = canvas.createCanvas(200, 100);
  JsBarcode(canvasElement, text, { format: 'EAN13' });
  const buffer = canvasElement.toBuffer('image/png');
  fs.writeFileSync(barcodePath, buffer);

  res.send(\`
    <h1>Barcode Generator</h1>
    <img src="/barcode.png" alt="Barcode" />
  \`);
});

// Start the server
app.listen(port, () => {
  console.log(\`Server running at http://localhost:\${port}\`);
});
EOL

# Start the server
echo "Starting server..."
node server.js
