"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = exports.ApiError = void 0;
class ApiError extends Error {
    constructor(statusCode, message) {
        super(message);
        this.statusCode = statusCode;
        this.name = 'ApiError';
    }
}
exports.ApiError = ApiError;
const errorHandler = (err, req, res, next) => {
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
exports.errorHandler = errorHandler;
