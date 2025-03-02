"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateGeminiResponseController = void 0;
const gemini_service_1 = require("../services/gemini_service");
const async_handler_1 = require("../middleware/async_handler");
const geminiService = new gemini_service_1.GeminiService();
exports.generateGeminiResponseController = (0, async_handler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { prompt } = req.body;
    const response = yield geminiService.generateResponse(prompt);
    res.status(200).json({
        success: true,
        data: {
            message: response.text,
            conversation: {
                currentMessage: {
                    role: "model",
                    content: response.text
                },
                history: response.history
            }
        }
    });
}));
