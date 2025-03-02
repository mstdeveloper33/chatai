"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const generate_gemini_controller_1 = require("../controllers/generate_gemini_controller");
const validation_middleware_1 = require("../middleware/validation_middleware");
const geminiRouter = (0, express_1.Router)();
geminiRouter.post("/", validation_middleware_1.validatePromptRequest, generate_gemini_controller_1.generateGeminiResponseController);
exports.default = geminiRouter;
