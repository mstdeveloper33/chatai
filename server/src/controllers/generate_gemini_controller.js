'use strict';

const { GeminiService } = require("../services/gemini_service");
const { asyncHandler } = require("../middleware/async_handler");
const { ApiError } = require("../middleware/error_handler");

/**
 * Gemini AI ile ilgili istekleri işleyen controller
 */
class GeminiController {
    /**
     * Controller yapıcı metodu
     * Dependency Injection ile servis alır veya varsayılan kullanır
     * @param {object} geminiService - Kullanılacak Gemini servisi
     */
    constructor(geminiService) {
        this.geminiService = geminiService || new GeminiService();
    }
    
    /**
     * Kullanıcının gönderdiği prompt'a yanıt üretir
     * @param {object} req - Express isteği
     * @param {object} res - Express yanıtı
     */
    generateResponse = asyncHandler(async (req, res) => {
        const { prompt } = req.body;

        // İstek validasyonu validation_middleware'de yapılıyor
        const response = await this.geminiService.generateResponse(prompt);
        
        const responseData = {
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
        };
        
        res.status(200).json(responseData);
    });
    
    /**
     * Sohbeti sıfırlar
     * @param {object} req - Express isteği
     * @param {object} res - Express yanıtı
     */
    resetChat = asyncHandler(async (req, res) => {
        this.geminiService.resetChat();
        
        res.status(200).json({
            success: true,
            message: "Sohbet sıfırlandı"
        });
    });
}

// Controller singleton instance
const geminiController = new GeminiController();

// Dışa aktarılan controller metotları
module.exports = {
    generateGeminiResponseController: geminiController.generateResponse,
    resetGeminiChatController: geminiController.resetChat
}; 