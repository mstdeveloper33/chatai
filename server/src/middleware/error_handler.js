'use strict';

/**
 * API hatalarını standart formatta taşıyan özel hata sınıfı
 */
class ApiError extends Error {
    /**
     * @param {number} statusCode - HTTP durum kodu
     * @param {string} message - Hata mesajı 
     */
    constructor(statusCode, message) {
        super(message);
        this.statusCode = statusCode;
        this.name = 'ApiError';
        Error.captureStackTrace(this, this.constructor);
    }
}

/**
 * Global hata işleme middleware'i
 * Tüm uygulama hatalarını yakalayarak standart bir formatta yanıt döner
 * 
 * @param {Error|ApiError} err - Yakalanan hata nesnesi
 * @param {object} req - Express isteği
 * @param {object} res - Express yanıtı
 * @param {function} next - Sonraki middleware
 */
const errorHandler = (err, req, res, next) => {
    // Loglama
    console.error('Hata yakalandı:', err);

    // Yanıt zaten gönderilmişse, Express'in kendi hata işleyicisine bırak
    if (res.headersSent) {
        return next(err);
    }

    // İstek bilgilerini logla
    console.error(`Hata üretilen istek: ${req.method} ${req.originalUrl}`);
    
    let errorResponse;

    // API Error kontrolü
    if (err instanceof ApiError) {
        errorResponse = {
            success: false,
            message: err.message,
            error: process.env.NODE_ENV === 'development' ? {
                stack: err.stack,
                name: err.name
            } : undefined
        };
        
        return res.status(err.statusCode).json(errorResponse);
    }

    // Varsayılan hata yanıtı (500 Internal Server Error)
    errorResponse = {
        success: false,
        message: "Sunucu hatası",
        error: process.env.NODE_ENV === 'development' ? {
            message: err.message,
            stack: err.stack,
            name: err.name
        } : undefined
    };
    
    res.status(500).json(errorResponse);
};

module.exports = {
    ApiError,
    errorHandler
}; 