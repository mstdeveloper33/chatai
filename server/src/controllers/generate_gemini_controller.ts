import { Request, Response } from "express";
import { GeminiService } from "../services/gemini_service";
import { asyncHandler } from "../middleware/async_handler";

const geminiService = new GeminiService();

export const generateGeminiResponseController = asyncHandler(async (req: Request, res: Response) => {
    const { prompt } = req.body;
    
    try {
        const response = await geminiService.generateResponse(prompt);
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
    } catch (error) {
        console.error("Controller Error:", error);
        res.status(500).json({ success: false, message: "İstek işlenirken bir hata oluştu" });
    }
});