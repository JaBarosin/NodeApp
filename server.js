'use strict';

const express = require('express');

// Constants
const PORT = 8000;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  res.send('Heyo from nodejs! Testing jenkins builds + cbctl scanning. Test no. 1.1 !!');
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
