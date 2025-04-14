'use strict';

const { Router } = require('express');
const helloRouter = Router();

helloRouter.get("/", (req, res) => {
    res.json({data : "Server is running"});
});

module.exports = helloRouter; 