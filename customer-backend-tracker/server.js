const express = require('express');
const bigtable = require('./bigtable');
require('dotenv').config();

// Initialize express app and bigtable instance.  
const port = process.env.PORT || 8080;
const app = express();
app.use(express.json()); // Let app communicate in jsons. 

const btInstance = new bigtable.BigTableReader(
    process.env.BT_INSTANCE,
    process.env.BT_TABLE,
);

// Get one package's latest location from the database.
app.post('/api/get', (req, res) => {
    btInstance.readRow(req.body.packageId, {
        row: {
            cellLimit: 1,
        }
    }).then(
        data => {
            console.log(data);
            res.status(200).send(data);
        }
    ).catch(err => {
        console.log(err);
        res.status(400).send(err);
    });
});

// Get one package's entire location history from the database.
app.post('/api/getAll', (req, res) => {
    btInstance.readRow(req.body.packageId).then(
        data => {
            console.log(data);
            res.status(200).send(data);
        }
    ).catch(err => {
        console.log(err);
        res.status(400).send(err);
    });
});

// Get multiple packages' latest locations from the database filtering by prefix. 
app.post('/api/getPrefix', (req, res) => {
    // TODO: implement prefix check.
    btInstance.readRowByPrefix(req.body.packageId, {
        row: {
            cellLimit: 1,
        }
    }).then(
        data => {
            console.log(data);
            res.status(200).send(data);
        }
    ).catch(err => {
        console.log(err);
        res.status(400).send(err);
    });
});

app.post('/api/getPrefixAll', (req, res) => {
    // TODO: implement prefix check.
    btInstance.readRowByPrefix(req.body.packageId).then(
        data => {
            console.log(data);
            res.status(200).send(data);
        }
    ).catch(err => {
        console.log(err);
        res.status(400).send(err);
    });
});

// Update a package entry. Will not update if the row with row-key did not exist before.
app.post('/api/update', (req, res) => {
    btInstance.updateRow(req.body.packageId, req.body.packageLocation).then(data => {
        console.log(data);
        res.status(200).send(data);
    }).catch(err => {
        console.log(err);
        res.status(400).send(err);
    });
});

// Create a package entry. Will not create if a row with row-key already exists.
app.post('/api/create', (req, res) => {
    btInstance.createRow(req.body.packageId, req.body.packageLocation).then(data =>
        res.status(200).send(data)
    ).catch(err => {
        console.log(err);
        res.status(400).send(err);
    });
});

// Test function to remove all entries starting with [0-9]
app.post('/api/test/clear', (req, res) => {
    btInstance.clearTable().then(data => res.status(200).send());
});

app.listen(port, () => console.log('App is listening on ' + port + '.'));
