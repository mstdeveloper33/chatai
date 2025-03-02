import { Router } from "express";
import { generateGeminiResponseController } from "../controllers/generate_gemini_controller";
import { validatePromptRequest } from "../middleware/validation_middleware";

const geminiRouter = Router();

geminiRouter.post("/", validatePromptRequest, generateGeminiResponseController);

export default geminiRouter;