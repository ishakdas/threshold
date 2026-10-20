# Eşik

Günün iki geçiş anında, yatmadan önce ve evden çıkmadan önce, kendi kontrol
listeni doğru anda önüne getiren uygulama. Hatırlatma sabit bir saatte değil,
seçtiğin bir davranış gerçekleştiğinde gelir: telefonu şarja takınca, alarmı
durdurunca, ev Wi‑Fi'ından ayrılınca.

Öncelik Android; iOS aynı Flutter koduyla sonra gelecek.

## Telefona kurmak

Her push'ta GitHub Actions bir APK üretir:

1. Repoda **Actions → Android** iş akışını açın, en son başarılı çalışmaya girin.
2. Sayfanın altındaki **Artifacts** bölümünden `esik-<numara>-apk` dosyasını indirin.
3. Zip'i açıp `app-release.apk` dosyasını telefona aktarın ve kurun
   (ilk seferde "Bilinmeyen uygulamaları yükle" izni istenir).

## Geliştirme

- Flutter 3.47.7 (stable)
- `flutter pub get`
- `flutter analyze && flutter test`
- `flutter run`

## Yapı

```
lib/
  core/        gün modu (akşam/sabah) ve ortak mantık
  theme/       renk token'ları (EsikPalette) ve tipografi
  ui/          paylaşılan bileşenler: atmosfer, cam sekme çubuğu, kapı görseli, ikonlar, logo
  features/    ekranlar
assets/
  fonts/       Inter (SIL OFL, bkz. assets/fonts/OFL.txt)
  brand/       mağaza ve iOS ikonları
```

## Yol haritası

1. **Kurulum** — proje, tema, logo, CI ✅
2. **Arayüz** — 7 ekranın tamamı, akşam/sabah modu, tik animasyonu
3. **Veri** — liste düzenleme, geçmiş (yerel veritabanı)
4. **Bildirimler** — "Hepsi tamam" eylemi, yedek saat
5. **Tetikleyiciler** — şarj, NFC, Wi‑Fi, alarm; ardından diğerleri
6. **İzin rehberi** — bildirim, pil optimizasyonu, konum/NFC
7. **Play Store** — dahili test kanalı
8. **iOS** — Kısayollar entegrasyonu
