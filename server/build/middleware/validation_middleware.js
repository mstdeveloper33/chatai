"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validatePromptRequest = void 0;
const error_handler_1 = require("./error_handler");
const validatePromptRequest = (req, res, next) => {
    const { prompt } = req.body;
    if (!prompt) {
        throw new error_handler_1.ApiError(400, "'prompt' alanı zorunludur");
    }
    if (typeof prompt !== 'string') {
        throw new error_handler_1.ApiError(400, "'prompt' alanı string tipinde olmalıdır");
    }
    if (prompt.trim().length === 0) {
        throw new error_handler_1.ApiError(400, "'prompt' alanı boş olamaz");
    }
    next();
};
exports.validatePromptRequest = validatePromptRequest;
