import { Router } from "express";
import helloRouter from "./hello_router";
import geminiRouter from "./gemini_router";

const router = Router();

router.use("/hello" , helloRouter);
router.use("/generate_response" , geminiRouter);

export default router;