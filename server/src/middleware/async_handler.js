'use strict';

/**
 * Asenkron controller fonksiyonlarını hata yakalama ile sarmalayan yardımcı fonksiyon
 * try/catch bloklarını tekrarlamadan Promise hatalarını global hata işleyiciye yönlendirir
 * 
 * @param {Function} fn - Sarmalanacak asenkron controller fonksiyonu
 * @returns {Function} Hata yakalama işlevselliği eklenmiş fonksiyon
 * 
 * @example
 * ```javascript
 * // Kullanım
 * const myController = asyncHandler(async (req, res) => {
 *   // Asenkron işlemler
 *   const data = await someAsyncOperation();
 *   res.json(data);
 * });
 * ```
 */
const asyncHandler = (fn) => {
    return (req, res, next) => {
        Promise.resolve(fn(req, res, next)).catch(next);
    };
};

module.exports = {
    asyncHandler
}; 