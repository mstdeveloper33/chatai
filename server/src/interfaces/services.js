'use strict';

/**
 * @typedef {Object} MessageDto
 * @property {string} role - Mesajın kimden geldiği - 'user' veya 'model'
 * @property {string} content - Mesaj içeriği
 */

/**
 * @typedef {Object} GeminiServiceResponse
 * @property {string} text - Yanıt metni
 * @property {Array<MessageDto>} history - Sohbet geçmişi
 */

/**
 * Gemini AI servisi için interface
 * Bu interface, Dependency Injection prensibine göre
 * servis implementasyonlarını değiştirmeyi kolaylaştırır
 * 
 * @interface
 */

/**
 * Gemini API'sine prompt göndererek yanıt üretir
 * 
 * @function
 * @name IGeminiService#generateResponse
 * @param {string} prompt - Kullanıcı tarafından gönderilen metin
 * @returns {Promise<GeminiServiceResponse>} Gemini tarafından üretilen yanıt ve sohbet geçmişi
 */

/**
 * Yeni bir sohbet oturumu başlatır, mevcut geçmişi temizler
 * 
 * @function
 * @name IGeminiService#resetChat
 * @returns {void}
 */

// Not: JavaScript'te interface ve tipler bulunmadığından, JSDoc kullanılarak
// dokümantasyon sağlanır.

module.exports = {}; 