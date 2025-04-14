'use strict';

/**
 * @typedef {Object} PromptRequestDto
 * @property {string} prompt - Kullanıcı tarafından gönderilen metin
 */

/**
 * @typedef {Object} MessageDto
 * @property {string} role - Mesajın kimden geldiği - 'user' veya 'model'
 * @property {string} content - Mesaj içeriği
 */

/**
 * @typedef {Object} ChatHistoryDto
 * @property {MessageDto} currentMessage - Mevcut mesaj
 * @property {Array<MessageDto>} history - Önceki mesajların listesi
 */

/**
 * @typedef {Object} GeminiResponseDto
 * @property {boolean} success - İşlem başarı durumu
 * @property {Object} data - Yanıt verileri
 * @property {string} data.message - Yanıt metni
 * @property {ChatHistoryDto} data.conversation - Sohbet verileri
 */

/**
 * @typedef {Object} ErrorResponseDto
 * @property {boolean} success - İşlem başarı durumu
 * @property {string} message - Hata mesajı
 * @property {*} [error] - Hata detayları (sadece development modunda)
 */

// Not: JavaScript'te interface bulunmadığından, bu dosya sadece
// dokümantasyon amacıyla JSDoc tiplerini tanımlar. Bu tipler,
// editörler tarafından kod tamamlama ve tip kontrolü için kullanılabilir.

module.exports = {}; // Boş bir nesne export ediyoruz, çünkü JavaScript'te interface'ler bulunmaz 