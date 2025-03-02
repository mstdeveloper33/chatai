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
exports.GeminiService = void 0;
const generative_ai_1 = require("@google/generative-ai");
class GeminiService {
    constructor() {
        console.log('GeminiService başlatılıyor...');
        const apiKey = process.env.GEMINI_API_KEY;
        if (!apiKey) {
            throw new Error('GEMINI_API_KEY bulunamadı!');
        }
        try {
            this.genAI = new generative_ai_1.GoogleGenerativeAI(apiKey);
            this.model = this.genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
            this.initializeChat();
            console.log('GeminiService başarıyla başlatıldı');
        }
        catch (error) {
            console.error("Gemini API başlatılırken hata:", error);
            throw error;
        }
    }
    initializeChat() {
        try {
            this.chat = this.model.startChat({
                generationConfig: {
                    maxOutputTokens: 2048,
                    temperature: 0.7,
                    topP: 0.8,
                    topK: 40,
                },
                history: []
            });
        }
        catch (error) {
            console.error("Chat başlatılırken hata:", error);
            throw error;
        }
    }
    generateResponse(prompt) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                if (!prompt || typeof prompt !== 'string') {
                    throw new Error('Geçersiz prompt formatı');
                }
                // Mesajı text olarak gönder
                const result = yield this.chat.sendMessage([{ text: prompt }]);
                const responseText = result.response.text();
                const history = yield this.chat.getHistory();
                return {
                    text: responseText,
                    history: history
                };
            }
            catch (error) {
                console.error("Gemini API Error:", error);
                throw new Error("İstek işlenirken bir hata oluştu");
            }
        });
    }
}
exports.GeminiService = GeminiService;
