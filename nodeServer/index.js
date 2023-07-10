const express = require('express');
const app = express();
const bodyParser = require('body-parser');

const port = 3001;

app.use(bodyParser.json());

app.post('/api/send-object', (req, res) => {
  const receivedObject = req.body;
  
  console.log('Received object:', receivedObject);
  
  res.sendStatus(200);
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});
