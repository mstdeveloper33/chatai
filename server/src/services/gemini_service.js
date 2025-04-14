'use strict';

const { GoogleGenerativeAI } = require("@google/generative-ai");
const { ApiError } = require("../middleware/error_handler");

/**
 * Gemini AI modeli ile etkileşim sağlayan servis sınıfı
 * Google Generative AI API'sini kullanarak metin tabanlı yanıtlar üretir
 */
class GeminiService {
    /**
     * Servis başlatıcı
     * API anahtarını kontrol eder ve chat oturumunu başlatır
     * @throws {ApiError} API anahtarı bulunamazsa veya bağlantı hatası olursa hata fırlatır
     */
    constructor() {
        const apiKey = process.env.GEMINI_API_KEY;
        if (!apiKey) {
            throw new ApiError(500, 'GEMINI_API_KEY bulunamadı! Lütfen .env dosyasını kontrol edin.');
        }

        try {
            this.genAI = new GoogleGenerativeAI(apiKey);
            this.model = this.genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
            this.initializeChat();
        } catch (error) {
            console.error("Gemini API başlatılırken hata:", error);
            throw new ApiError(500, "Gemini AI servisi başlatılamadı!");
        }
    }

    /**
     * Chat oturumunu başlatır veya sıfırlar
     * @private
     */
    initializeChat() {
        try {
            this.chat = this.model.startChat({
                generationConfig: {
                    maxOutputTokens: 2048, // Maksimum token sayısı
                    temperature: 0.7,      // Yaratıcılık seviyesi (0-1)
                    topP: 0.8,             // Olasılık eşiği
                    topK: 40,              // Seçilecek maksimum token sayısı
                },
                history: []
            });
        } catch (error) {
            console.error("Chat başlatılırken hata:", error);
            throw new ApiError(500, "Sohbet oturumu başlatılamadı!");
        }
    }

    /**
     * Yeni bir sohbet oturumu başlatır, mevcut geçmişi temizler
     */
    resetChat() {
        this.initializeChat();
    }

    /**
     * Verilen promptu kullanarak yanıt üretir
     * @param {string} prompt - Kullanıcının gönderdiği metin
     * @returns {Promise<Object>} Yanıt metni ve sohbet geçmişi
     * @throws {ApiError} İstek geçersizse veya API hatası olursa hata fırlatır
     */
    async generateResponse(prompt) {
        try {
            if (!prompt || typeof prompt !== 'string') {
                throw new ApiError(400, 'Geçersiz prompt formatı');
            }
    
            // Modele mesaj gönder
            const result = await this.chat.sendMessage(prompt);
            const responseText = result.response.text();
            const history = await this.chat.getHistory();
    
            return {
                text: responseText,
                history: history
            };
        } catch (error) {
            if (error instanceof ApiError) {
                throw error;
            }
            
            console.error("Gemini API Error:", error);
            
            // İstemci tarafı hataları için 400, sunucu/API hataları için 500
            const statusCode = 
                error.message?.includes('Invalid') || 
                error.message?.includes('geçersiz') ? 400 : 500;
                
            throw new ApiError(statusCode, "AI yanıtı üretilirken bir hata oluştu");
        }
    }
}

module.exports = { GeminiService }; 