import { GenerativeModel, GoogleGenerativeAI } from "@google/generative-ai";

export class GeminiService {
    private genAI: GoogleGenerativeAI;
    private model: GenerativeModel;
    private chat: any;

    constructor() {
        console.log('GeminiService başlatılıyor...');
        
        const apiKey = process.env.GEMINI_API_KEY;
        if (!apiKey) {
            throw new Error('GEMINI_API_KEY bulunamadı!');
        }

        try {
            this.genAI = new GoogleGenerativeAI(apiKey);
            this.model = this.genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
            this.initializeChat();
            console.log('GeminiService başarıyla başlatıldı');
        } catch (error) {
            console.error("Gemini API başlatılırken hata:", error);
            throw error;
        }
    }

    private initializeChat() {
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
        } catch (error) {
            console.error("Chat başlatılırken hata:", error);
            throw error;
        }
    }

    async generateResponse(prompt: string) {
        try {
            if (!prompt || typeof prompt !== 'string') {
                throw new Error('Geçersiz prompt formatı');
            }
    
            // Doğru format: string olarak gönder
            const result = await this.chat.sendMessage(prompt);
            const responseText = result.response.text();
            const history = await this.chat.getHistory();
    
            return {
                text: responseText,
                history: history
            };
        } catch (error) {
            console.error("Gemini API Error:", error);
            throw new Error("İstek işlenirken bir hata oluştu");
        }
    }
}