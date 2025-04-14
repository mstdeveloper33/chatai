'use strict';

const path = require('path');
const dotenv = require('dotenv');
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const helmet = require('helmet');
const router = require('./routes/routes');
const { errorHandler, ApiError } = require('./middleware/error_handler');

/**
 * Ana server uygulaması
 * 
 * Bu dosya sunucu yapılandırmasını içerir:
 * - Çevre değişkenlerini yükler
 * - Express uygulamasını başlatır
 * - Güvenlik middleware'lerini yapılandırır
 * - API rotalarını tanımlar
 * - Hata işleyiciyi yapılandırır
 */

// .env dosyası yapılandırması
dotenv.config({ path: path.join(__dirname, '../.env') });

// Express uygulaması
const app = express();
const PORT = process.env.PORT || 3000;

// Güvenlik middleware'leri
app.use(helmet()); // Temel güvenlik başlıkları
app.use(cors()); // CORS yapılandırması
app.use(bodyParser.json({ limit: '1mb' })); // JSON body parsing, boyut sınırı ile
app.use(bodyParser.urlencoded({ extended: true, limit: '1mb' }));

// API anahtarı kontrolü
if (!process.env.GEMINI_API_KEY) {
    console.error('UYARI: GEMINI_API_KEY bulunamadı! Lütfen .env dosyasını kontrol edin.');
    process.exit(1);
}

// API versiyonu ve rotaları
app.use('/api/v1', router);

// 404 handler - tanımlanmamış rotalar için
app.use((req, res, next) => {
    next(new ApiError(404, `Bulunamadı: ${req.originalUrl}`));
});

// Hata yakalama middleware'i
app.use(errorHandler);

// Sunucuyu başlat
app.listen(PORT, () => {
    console.log(`✅ Sunucu çalışıyor: http://localhost:${PORT}`);
    console.log(`📝 API endpoints: http://localhost:${PORT}/api/v1`);
    console.log(`🔒 Ortam: ${process.env.NODE_ENV || 'development'}`);
}); 