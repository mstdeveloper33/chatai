'use strict';

const { Router } = require("express");
const helloRouter = require("./hello_router");
const geminiRouter = require("./gemini_router");

/**
 * Ana API rotalarını yapılandıran router
 */
const router = Router();

/**
 * @route   /api/v1/hello
 * @desc    Test endpoint'leri
 */
router.use("/hello", helloRouter);

/**
 * @route   /api/v1/generate_response
 * @desc    Gemini AI yanıt üretme endpoint'leri
 */
router.use("/generate_response", geminiRouter);

module.exports = router; 