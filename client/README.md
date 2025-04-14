# AI Chat Uygulaması

Bu Flutter uygulaması, AI ile sohbet etmek için geliştirilmiş bir mobil uygulama projesidir. MVVM (Model-View-ViewModel) mimari deseni kullanılarak geliştirilmiştir ve SOLID prensiplerini uygulamaktadır.

## Proje Mimarisi

Uygulama, modüler bir yapıda tasarlanmış ve aşağıdaki ana bileşenlerden oluşmaktadır:

### 1. Çekirdek (Core)
- **DI (Dependency Injection)**: Uygulamanın bağımlılıklarını yönetir, kodun test edilebilirliğini ve modülerliğini artırır.

### 2. Veritabanı (Database)
- **DatabaseHelper**: SQLite veritabanı işlemlerini gerçekleştiren yardımcı sınıf. Singleton tasarım desenini kullanır.

### 3. Özellikler (Features)
Her özellik kendi içinde aşağıdaki katmanlara ayrılmıştır:

#### 3.1. Model
- Veri modellerini içerir (ConversationModel, ChatMessageModel vb.)
- Veritabanı ve API servislerinde kullanılan dönüşüm metodlarını içerir

#### 3.2. Repository
- **IConversationRepository**: Repository için arayüz sınıfı (interface)
- **ConversationRepository**: Veritabanı işlemlerini soyutlayan sınıf. SOLID prensiplerini uygular.

#### 3.3. ViewModel (Provider)
- **ConversationProvider**: UI ve veri katmanı arasında köprü görevi görür. UI'dan gelen istekleri repository'ye iletir ve sonuçları UI'a bildirir.
- **ChatProvider**: Sohbet işlevselliği için gereken veri işlemleri ve durumunu yönetir.

#### 3.4. View (UI)
- Ekranlar, sayfalar ve özel bileşenler
- Yalnızca ViewModel ile etkileşime girer, doğrudan veritabanı veya repository ile iletişim kurmaz.

### 4. Tasarım (Design)
- **AppTheme**: Uygulama genelinde tutarlı bir görünüm için tema tanımlamaları

## Kullanılan Mimari Desenler ve Prensipler

### MVVM (Model-View-ViewModel)
- **Model**: Veritabanı ve veri sınıfları
- **View**: UI bileşenleri
- **ViewModel**: View ve Model arasındaki iletişimi yöneten Provider sınıfları

### Repository Pattern
- Veritabanı erişimini soyutlar
- Unit test'leri kolaylaştırır
- Bağımlılıkları azaltır

### Dependency Injection
- Bağımlılıkların merkezi yönetimi
- Test edilebilirliği artırır
- Sınıflar arası gevşek bağlantı sağlar

### SOLID Prensipleri
1. **Single Responsibility**: Her sınıf tek bir sorumluluk alanına sahiptir
2. **Open/Closed**: Sınıflar genişlemeye açık, değişime kapalıdır
3. **Liskov Substitution**: Alt sınıflar, üst sınıfların yerine geçebilir
4. **Interface Segregation**: Küçük ve özelleşmiş arayüzler kullanılır
5. **Dependency Inversion**: Yüksek seviyeli modüller, düşük seviyeli ayrıntılara bağlı değildir

## Veritabanı Şeması

Uygulama SQLite veritabanını kullanır ve aşağıdaki tabloları içerir:

1. **conversations**
   - id: INTEGER (PRIMARY KEY)
   - title: TEXT
   - created_at: TEXT (ISO8601 formatında)
   - updated_at: TEXT (ISO8601 formatında)
   - is_archived: INTEGER (0 veya 1)

2. **messages**
   - id: INTEGER (PRIMARY KEY)
   - conversation_id: INTEGER (FOREIGN KEY)
   - role: TEXT (user veya assistant)
   - content: TEXT
   - created_at: TEXT (ISO8601 formatında)

## Kurulum ve Çalıştırma

1. Flutter'ı yükleyin: https://flutter.dev/docs/get-started/install
2. Projeyi klonlayın
3. Bağımlılıkları yükleyin: `flutter pub get`
4. Uygulamayı çalıştırın: `flutter run`

## Geliştirme Notları

- Her kod değişikliği için yorum satırları eklenmiştir
- Sınıflar ve metotlar Türkçe açıklamalarla belgelenmiştir
- Hata yönetimi için try-catch blokları kullanılmıştır
- Türkçe hata mesajları sağlanmıştır
