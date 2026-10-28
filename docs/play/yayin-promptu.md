Eşik adlı Android uygulamamı Google Play'de dahili teste hazırlamanı istiyorum.
Play Console'u Chrome üzerinden benim hesabımla kullanacaksın.

## Kaynaklar

Proje bilgisayarımda: `threshold` deposu (GitHub Desktop ile klonlu, `esik-plus` dalı).
Önce bu dalın güncel olduğundan emin ol, sonra şu dosyaları baştan sona oku:

- `docs/play/magaza.md`: uygulama adı, kısa ve tam açıklama, kategori, etiketler, sürüm notu
- `docs/play/console-formlari.md`: uygulama içi ürün, gizlilik politikası adresi,
  reklamlar, uygulama erişimi, içerik derecelendirmesi, hedef kitle, veri
  güvenliği, hassas izinler (pil optimizasyonu gerekçesi)
- `docs/play/gorseller/`: `ikon-512.png` (simge) ve her dil için
  `tr/`, `en/`, `es/` klasörlerinde `1.png`…`7.png` (telefon ekran görüntüleri,
  bu sırayla) ve `one-cikan-1024x500.png` (öne çıkan grafik)

Bu dosyalardaki cevaplar kesindir; formlarda onlara uy, kendi tahminini
yazma. Bir soru dosyalarda yoksa ya da ekrandaki seçenekler dosyadakiyle
uyuşmuyorsa dur ve bana sor.

## Kurallar

- Google hesabına girişi, iki adımlı doğrulamayı ve kimlik doğrulamayı ben
  yaparım; gerektiğinde dur ve beni bekle.
- **Ödeme profili, banka, vergi ve kimlik bilgilerine dokunma.** Bu ekranlar
  gelirse dur, bana söyle; ben dolduracağım.
- Sözleşme ya da şart kabul eden kutuları işaretlemeden önce bana sor.
- **Üretime (Production), kapalı ya da açık teste sürüm gönderme.** Yalnızca
  **Dahili test** kanalını kullan. İncelemeye gönderme ve yayınlama
  düğmelerine benden açık onay almadan basma.
- Her büyük adımdan sonra (uygulama oluşturma, mağaza girişi, her form, sürüm,
  ürün) ne yaptığını kısaca özetle.

## Yapılacaklar (sırayla)

1. **Uygulamayı oluştur** (yoksa):
   - Ad: `Eşik: Ütü, Ocak, Kapı Kontrolü`
   - Varsayılan dil: Türkçe (tr-TR)
   - Tür: Uygulama
   - Ücret: Ücretsiz

   Ücretsizdir çünkü Plus uygulama içinden satılır. Beyan kutularını
   işaretlemeden önce bana sor.

2. **Ana mağaza girişi (tr-TR):** `magaza.md` dosyasındaki ad, kısa açıklama
   ve tam açıklamayı olduğu gibi gir. Tam açıklama, kod bloğunun içindeki
   metindir. Grafikler `gorseller/tr/` ve `ikon-512.png`.
   Kategori: Verimlilik. Etiketleri de ekle. İletişim e-postası:
   `developerishak@gmail.com`.

3. **Çeviriler: en-US ve es-ES mağaza girişleri.** Ad, kısa ve tam açıklama
   `magaza.md` dosyasında her dil için hazır; olduğu gibi gir. Grafikler
   `gorseller/en/` ve `gorseller/es/`.

4. **Uygulama içeriği formları:** `console-formlari.md` dosyasına göre
   gizlilik politikası, reklamlar, uygulama erişimi, içerik
   derecelendirmesi, hedef kitle ve veri güvenliği. Pil optimizasyonu izni
   sorulursa dosyadaki gerekçeyi kullan.

5. **Dahili test sürümü:**
   - Test → Dahili test → Yeni sürüm oluştur.
   - Play Uygulama İmzalama'yı (Play App Signing) kabul etmeden önce bana
     sor.
   - AAB dosyası: GitHub'da `ishakdas/threshold` → Actions → `esik-plus`
     dalındaki en son başarılı "Android" çalıştırması → Artifacts →
     `-aab` ile biten dosya. İndir, zip'ten çıkar, `.aab` dosyasını yükle.
     AAB yoksa dur ve bana söyle.
   - Sürüm notu `magaza.md` dosyasında.
   - Test kullanıcısı olarak kendi Gmail adresimi ekle (bana sor).
   - Sürümü dahili teste göndermeden önce onayımı al.

6. **Uygulama içi ürün:** Para kazanma → Ürünler → Uygulama içi ürünler.
   `esik_plus` ürününü `console-formlari.md` dosyasındaki bilgilerle oluştur
   (49 TL, tek seferlik) ve etkinleştir. Ödeme profili tamamlanmadığı için
   bu ekran açılmıyorsa dur ve bana söyle.

7. **Lisans testi:** Ayarlar → Lisans testi altına kendi Gmail adresimi ekle
   (bana sor).

8. **Lisans anahtarı:** Para kazanma ayarları → Lisanslama bölümündeki
   "MIIB…" ile başlayan Base64 RSA ortak anahtarını kopyala ve bana göster.
   Bunu uygulamadaki satın alma doğrulamasına ekleteceğim.

## En sonda

Bana kısa bir rapor ver. Raporda şunlar olsun:

- Tamamlanan adımlar
- Bekleyen ve benim yapmam gerekenler
- Play Console'un kontrol panelinde ("Uygulamanızı kurun" listesi) hâlâ eksik
  görünen maddeler
- Lisans anahtarı
