'use strict';

const { Router } = require("express");
const { 
    generateGeminiResponseController,
    resetGeminiChatController
} = require("../controllers/generate_gemini_controller");
const { validatePromptRequest } = require("../middleware/validation_middleware");

/**
 * Gemini AI ile ilgili route'ları tanımlayan router
 */
const geminiRouter = Router();

/**
 * @route   POST /api/v1/generate_response
 * @desc    AI yanıtı üretir
 * @access  Public
 */
geminiRouter.post("/", validatePromptRequest, generateGeminiResponseController);

/**
 * @route   POST /api/v1/generate_response/reset
 * @desc    Sohbet geçmişini sıfırlar
 * @access  Public
 */
geminiRouter.post("/reset", resetGeminiChatController);

module.exports = geminiRouter; 