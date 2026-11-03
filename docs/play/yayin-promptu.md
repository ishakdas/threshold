Eşik adlı Android uygulamamın **1.1 sürümünü** Google Play'de yayına hazırlamanı
istiyorum. Play Console'u Chrome üzerinden benim hesabımla kullanacaksın.

## Durum (yaptıklarını önce Console'da doğrula)

Daha önce yapılanlar; Console'da gerçekten böyle olduğunu kontrol et, farklıysa
bana söyle:

- Uygulama oluşturuldu: **Eşik: Doğru Anda Hatırlatıcı**, paket
  `com.ishakdas.threshold`, varsayılan dil Türkçe.
- Dahili test kanalında 1.0 sürümü (sürüm kodu 37 civarı) var.
- Uygulama içi ürün `esik_plus` (tek seferlik, Türkiye 19,99 TL) oluşturuldu.
- Lisans testi listesi ayarlı.
- Türkçe, İngilizce ve İspanyolca mağaza girişleri ile formlar 1.0'a göre
  dolduruldu.

1.1'de değişenler ve Console'a yansıması gerekenler:

- Yeni özellikler: günlere göre farklı eşikler, hazır düzenler, hazır madde
  paketleri, maddeye özel gün ve hava durumu, "Kilitledim mi?" fotoğrafı, ana
  ekran widget'ı, tekrar hatırlatma, "İnterneti kapatınca" tetikleyicisi.
- **Veri güvenliği değişti.** Uygulama artık iki şeyi telefondan dışarı
  gönderiyor; 1.0'daki "veri toplamıyoruz" beyanı artık yanlış:
  - Deneme süresinin baştan başlamaması için cihaz kimliğinin SHA-256 özeti
    Eşik'in sunucusuna (Cloudflare) gidiyor.
  - Kullanıcı şehir seçerse, şehrin koordinatları hava tahmini için
    Open-Meteo'ya gidiyor.
- Mağaza metinleri ve 7 ekran görüntüsü yenilendi.

## Kaynaklar

Proje bilgisayarımda: `threshold` deposu (GitHub Desktop ile klonlu). Önce
**`main` dalına geç ve güncelle** (Fetch/Pull), sonra şu dosyaları baştan sona
oku:

- `docs/play/magaza.md`: üç dilde ad, kısa ve tam açıklama, kategori,
  etiketler, **"Sürüm 1.1" sürüm notu**.
- `docs/play/console-formlari.md`: uygulama içi ürün, gizlilik politikası
  adresi, reklamlar, oturum açma bilgileri, içerik derecelendirmesi, hedef
  kitle, **veri güvenliği (yeni hâli)**, hassas izinler.
- `docs/gizlilik.md`: gizlilik politikasının güncel metni.
- `docs/play/gorseller/`: `ikon-512.png` (simge) ve her dil için `tr/`, `en/`,
  `es/` klasörlerinde `1.png`…`7.png` (telefon ekran görüntüleri, bu sırayla)
  ile `one-cikan-1024x500.png` (öne çıkan grafik).

Bu dosyalardaki cevaplar kesindir; formlarda onlara uy, kendi tahminini yazma.
Bir soru dosyalarda yoksa ya da ekrandaki seçenekler dosyadakiyle uyuşmuyorsa
dur ve bana sor.

## Kurallar

- Google hesabına girişi, iki adımlı doğrulamayı ve kimlik doğrulamayı ben
  yaparım; gerektiğinde dur ve beni bekle.
- **Ödeme profili, banka, vergi ve kimlik bilgilerine dokunma.** Bu ekranlar
  gelirse dur, bana söyle; ben dolduracağım.
- Sözleşme ya da şart kabul eden kutuları işaretlemeden önce bana sor.
- **Üretime (Production) ya da kapalı/açık teste benden açık onay almadan
  sürüm gönderme.** İncelemeye gönder ve yayınla düğmelerine onaysız basma.
  Dahili teste gönderebilirsin.
- `esik_plus` ürününün kimliğini ve fiyatını değiştirme.
- Her büyük adımdan sonra (sürüm, mağaza girişi, her form) ne yaptığını kısaca
  özetle.

## Yapılacaklar (sırayla)

1. **Gizlilik politikası sayfasını kontrol et.**
   https://ishakdas.github.io/esik-gizlilik/ sayfasını aç. Sayfada "Open-Meteo"
   ve "deneme" (deneme süresi kaydı) geçmeli; `docs/gizlilik.md` ile aynı
   olmalı. Değilse dur ve bana söyle. Benim onayımla, bilgisayarımdaki
   `esik-gizlilik` deposunda `index.md`'yi `threshold/docs/gizlilik.md`'nin
   içeriğiyle değiştirip commit ve push edebilirsin; birkaç dakika sonra sayfa
   güncellenir. Veri güvenliği formundan önce sayfa güncel olmalı.

2. **AAB'yi al.** GitHub'da `ishakdas/threshold` → **Actions** → **Android**
   iş akışında `main` dalının en son **başarılı** çalıştırması → **Artifacts**
   → `esik-<numara>-aab`. İndir ve zip'ten çıkar. Bu derleme `1.1.0` sürüm
   adını taşımalı (Console yüklemede gösterir). Sürüm kodu, Console'daki son
   yüklenen sürümden büyük olmalı. Değilse ya da `main`'de başarılı çalıştırma
   yoksa dur ve bana söyle.

3. **Dahili test sürümü.** Test → Dahili test → Yeni sürüm oluştur:
   - AAB'yi yükle.
   - Sürüm notu: `magaza.md` dosyasındaki "Sürüm 1.1" bloğu (üç dil).
   - Console izinlerle ilgili bir uyarı ya da beyan isterse dur ve bana söyle.
     1.1'deki yeni izinler normal izinlerdir: `INTERNET`,
     `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`. Kamera izni yok; fotoğraf,
     telefonun kamera uygulamasıyla çekiliyor.
   - Dahili teste gönder.

4. **Mağaza girişini güncelle** (tr-TR, en-US, es-ES ayrı ayrı):
   - Tam açıklamayı `magaza.md`'deki yeni hâliyle değiştir. Ad ve kısa açıklama
     aynı kaldıysa dokunma.
   - Telefon ekran görüntülerinin hepsini sil, `<dil>/1.png`…`7.png`'yi bu
     sırayla yükle. Öne çıkan grafiği `<dil>/one-cikan-1024x500.png` ile
     değiştir.
   - Kaydet. Yayınlama ya da incelemeye gönderme adımı çıkarsa onay almadan
     geçme.

5. **Veri güvenliği formunu yeniden doldur.** `console-formlari.md` →
   "Veri güvenliği" bölümündeki tabloya birebir uy:
   - Veri topluyor ya da paylaşıyor mu: **Evet**. Aktarım şifreli: **Evet**.
     Silme talebi: **Evet**, e-postayla.
   - **Cihaz veya diğer kimlikler:** Toplanıyor, paylaşılmıyor. Amacı
     dolandırıcılığı önleme. İsteğe bağlı değil.
   - **Yaklaşık konum:** Toplanıyor ama geçici olarak işleniyor, paylaşılmıyor.
     Amacı uygulama işlevi. İsteğe bağlı (yalnızca şehir seçilirse).
   - Fotoğraflar telefondan çıkmadığı için beyan edilmez.

   Formun önizlemesini bana göster, onaylarsam kaydet.

6. **Diğer formları kontrol et.** Reklamlar, oturum açma bilgileri, içerik
   derecelendirmesi ve hedef kitle `console-formlari.md` ile aynı mı bak.
   Farklıysa düzelt. Console bir formu "güncelleme gerekiyor" diye
   işaretlediyse bana söyle.

7. **Uygulama içi ürünü kontrol et.** Para kazanma → Ürünler → Tek seferlik
   ürünler. `esik_plus` **etkin** olmalı, Türkiye fiyatı 19,99 TL olmalı.
   Değilse bana söyle; değiştirme.

8. **Üretim için durumu öğren, ama gönderme.** Kontrol paneli → "Uygulamanızı
   yayınlayın" listesinde eksik kalan her şeyi not et. Console üretimden önce
   kapalı test istiyorsa ("en az 12 test kullanıcısı, 14 gün" gibi) bunu da
   not et. Üretime ya da kapalı teste **gönderme**; bana sor.

## En sonda

Bana kısa bir rapor ver:

- Tamamlanan adımlar ve yüklenen sürüm (sürüm adı ve kodu).
- Gizlilik politikası sayfasının durumu.
- Veri güvenliği formunun son hâli (özet).
- Üretim için eksik kalanlar ve benim yapmam gerekenler.
- Karşılaştığın uyarılar ya da hatalar.
