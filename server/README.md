# AI Chat API Server

Bu proje, AI Chat uygulaması için backend API sunucusudur. TypeScript ve Express.js kullanılarak geliştirilmiştir. Google Gemini AI API'si ile entegre çalışır.

## Özellikler

- Express.js tabanlı REST API
- Google Gemini 1.5 Flash modeli ile entegrasyon
- TypeScript ile tip güvenliği
- SOLID prensiplerine uygun mimari
- Clean Code prensiplerine uygun kod yapısı
- Güvenlik önlemleri (Helmet, request limiting)
- Ayrıntılı hata yönetimi

## Mimari

Proje, modüler bir yapıda ve klasik 3-katmanlı mimari kullanılarak tasarlanmıştır:

### 1. Presentation Layer (Sunum Katmanı)
- **routes**: API endpoint tanımlamaları
- **controllers**: İstekleri işleyen controller sınıfları
- **middleware**: İstek işleme zincirini düzenleyen ara katman fonksiyonları

### 2. Business Layer (İş Mantığı Katmanı)
- **services**: İş mantığını ve harici API entegrasyonlarını içeren servisler

### 3. Data Layer (Veri Katmanı)
- **repositories** (şu an aktif değil): Veritabanı işlemleri için repository sınıfları

### Diğer Bileşenler
- **interfaces**: Tip tanımları ve arayüzler
- **middleware/error_handler.ts**: Global hata yönetimi
- **middleware/async_handler.ts**: Asenkron işlemleri basitleştiren yardımcı fonksiyon

## Teknolojiler

- **Express.js**: Web sunucusu çerçevesi
- **TypeScript**: Tip güvenliği için
- **Google Generative AI**: Gemini AI modeli için
- **Helmet**: Güvenlik başlıkları
- **CORS**: Cross-Origin isteklerini yönetmek için
- **dotenv**: Çevre değişkenleri yönetimi

## API Endpoints

### 1. Generate AI Response
- **Endpoint**: `POST /api/v1/generate_response`
- **Description**: Kullanıcının gönderdiği metne yapay zeka yanıtı üretir
- **Request Body**:
  ```json
  {
    "prompt": "Merhaba, Türkiye'nin başkenti neresidir?"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "message": "Türkiye'nin başkenti Ankara'dır.",
      "conversation": {
        "currentMessage": {
          "role": "model",
          "content": "Türkiye'nin başkenti Ankara'dır."
        },
        "history": [...]
      }
    }
  }
  ```

### 2. Reset Chat Session
- **Endpoint**: `POST /api/v1/generate_response/reset`
- **Description**: Mevcut sohbet oturumunu sıfırlar
- **Response**:
  ```json
  {
    "success": true,
    "message": "Sohbet sıfırlandı"
  }
  ```

## Kurulum ve Çalıştırma

### Ön Gereksinimler
- Node.js (v16 veya üzeri)
- npm veya yarn

### Kurulum
1. Projeyi klonlayın
2. Bağımlılıkları yükleyin:
   ```bash
   npm install
   ```
3. `.env` dosyası oluşturun ve gerekli değişkenleri tanımlayın:
   ```
   GEMINI_API_KEY=your_api_key_here
   NODE_ENV=development
   PORT=3000
   ```

### Geliştirme
```bash
npm run dev
```

### Derleme ve Çalıştırma
```bash
npm run build
npm start
```

## Mimari Notlar

- **Dependency Injection**: Servisler ve controllerlar, birim testleri kolaylaştırmak için bağımlılıkları parametre olarak alabilir.
- **Interface-First Approach**: Servisler, arayüzleri (interfaces) takip eder, bu sayede farklı implementasyonlar kolayca değiştirilebilir.
- **Error Handling**: Tüm uygulama genelinde standart hata işleme yaklaşımı kullanılır.
- **Middleware Pattern**: İstek işleme, doğrulama ve hata işleme için middleware deseni kullanılır.

## Güvenlik

- Helmet ile güvenlik başlıkları uygulanır
- İstek gövdesi boyutu sınırlandırılır (1MB)
- API anahtarları çevre değişkenleri ile yönetilir
- Hata mesajları production modunda sınırlandırılır 