import { Request, Response, NextFunction } from 'express';
import { ApiError } from './error_handler';

export const validatePromptRequest = (req: Request, res: Response, next: NextFunction) => {
    const { prompt } = req.body;

    if (!prompt) {
        throw new ApiError(400, "'prompt' alanı zorunludur");
    }

    if (typeof prompt !== 'string') {
        throw new ApiError(400, "'prompt' alanı string tipinde olmalıdır");
    }

    if (prompt.trim().length === 0) {
        throw new ApiError(400, "'prompt' alanı boş olamaz");
    }

    next();
};