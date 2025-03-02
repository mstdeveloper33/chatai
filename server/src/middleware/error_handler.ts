import { Request, Response, NextFunction } from 'express';

export class ApiError extends Error {
    statusCode: number;
    
    constructor(statusCode: number, message: string) {
        super(message);
        this.statusCode = statusCode;
        this.name = 'ApiError';
    }
}

export const errorHandler = (
    err: Error | ApiError,
    req: Request,
    res: Response,
    next: NextFunction
) => {
    console.error('Hata yakalandı:', err);

    if (res.headersSent) {
        return next(err);
    }

    // API Error kontrolü
    if (err instanceof ApiError) {
        return res.status(err.statusCode).json({
            success: false,
            message: err.message,
            error: process.env.NODE_ENV === 'development' ? err.stack : undefined
        });
    }

    // Genel hata yanıtı
    res.status(500).json({
        success: false,
        message: "Sunucu hatası",
        error: process.env.NODE_ENV === 'development' ? err.message : 'Bir hata oluştu'
    });
};