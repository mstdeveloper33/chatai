'use strict';

const { ApiError } = require('./error_handler');

/**
 * Prompt isteklerinin geçerliliğini kontrol eden middleware
 * 
 * @param {object} req - Express isteği
 * @param {object} res - Express yanıtı
 * @param {function} next - Sonraki middleware
 * @throws {ApiError} - Validasyon hatası durumunda 400 hata kodu ile fırlatılır
 */
const validatePromptRequest = (req, res, next) => {
    const { prompt } = req.body;

    // Prompt var mı?
    if (!prompt) {
        throw new ApiError(400, "'prompt' alanı zorunludur");
    }

    // Prompt doğru tipte mi?
    if (typeof prompt !== 'string') {
        throw new ApiError(400, "'prompt' alanı string tipinde olmalıdır");
    }

    // Prompt boş mu?
    if (prompt.trim().length === 0) {
        throw new ApiError(400, "'prompt' alanı boş olamaz");
    }

    // Maksimum uzunluk kontrolü (opsiyonel)
    const MAX_PROMPT_LENGTH = 4000; // Gemini API sınırı
    if (prompt.length > MAX_PROMPT_LENGTH) {
        throw new ApiError(400, `'prompt' alanı ${MAX_PROMPT_LENGTH} karakterden uzun olamaz`);
    }

    next();
};

module.exports = {
    validatePromptRequest
}; 