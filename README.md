# TechStore — Flutter Teknoloji Alışveriş Uygulaması

TechStore, Flutter ve Dart kullanılarak geliştirilen bir mobil teknoloji ürünleri katalog uygulamasıdır. Kullanıcılar uygulama üzerinden ürünleri inceleyebilir, arama yapabilir, kategorilere göre filtreleyebilir, ürün detaylarını görüntüleyebilir ve simüle edilmiş bir alışveriş sepetini yönetebilir.

## Özellikler

- **Ürün Kataloğu:** Teknoloji ürünlerini ızgara düzeninde görüntüleme.
- **Ürün Görselleri:** Yerel görsel dosyalarını kullanarak ürün fotoğraflarını gösterme.
- **Ürün Arama:** Ürün adına göre arama yapma.
- **Kategori Filtreleme:** Ürünleri kategorilerine göre filtreleme.
- **Ürün Detayları:** Ürün görselini, açıklamasını ve fiyatını görüntüleme.
- **Alışveriş Sepeti:** Sepete ürün ekleme ve ürün adetlerini artırma veya azaltma.
- **Otomatik Fiyat Hesaplama:** Ürün adetlerine göre sepet toplamını hesaplama.
- **JSON Veri Yönetimi:** Ürün bilgilerini yerel bir JSON dosyasından yükleme.

## Kullanılan Teknolojiler

- Flutter
- Dart
- Material Design
- JSON
- Yerel görsel dosyaları (Assets)

## Proje Dosya Yapısı

```text
lib/
├── main.dart
├── models/
│   └── product.dart
└── data/
    └── products.json

assets/
└── image/
    ├── Headphones.jpg
    ├── Keyboard.jpg
    ├── Smartphone.jpg
    ├── Mouse.jpg
    ├── Laptop.png
    └── watch.jpg
```

## Kurulum ve Çalıştırma

### Gereksinimler

- Flutter SDK
- Dart SDK (Flutter ile birlikte gelir)
- Android Studio veya Visual Studio Code
- Android emülatörü ya da uyumlu bir cihaz

### Kurulum Adımları

1. Projeyi GitHub üzerinden bilgisayarınıza indirin:

   ```bash
   git clone GITHUB_DEPO_ADRESI
   ```

2. Proje klasörüne geçin:

   ```bash
   cd mobil_gelistirme_projesi
   ```

3. Gerekli paketleri yükleyin:

   ```bash
   flutter pub get
   ```

4. Uygulamayı çalıştırın:

   ```bash
   flutter run
   ```

## Ekran Görüntüleri

Uygulamanın ekran görüntüleri aşağıdaki bölümlere eklenecektir.

### Ana Sayfa

![TechStore Ana Sayfa](screenshots/home.png)

### Ürün Detay Ekranı

![TechStore Ürün Detay Ekranı](screenshots/product-details