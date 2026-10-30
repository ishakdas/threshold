# iOS — yayına alma

Kod `ios` dalında. CI (`.github/workflows/ios.yml`) her değişiklikte
uygulamayı imzasız derler; imzalama, telefonda deneme ve App Store'a
yükleme Mac'te Xcode ile yapılır.

## iOS'ta neler farklı

iOS uygulamaların şarjı, alarmı ya da Wi‑Fi'ı görmesine izin vermiyor. Bu
yüzden tetikleyiciler **Kestirmeler otomasyonlarıyla** çalışır: kullanıcı
örneğin "Şarj Cihazı → Bağlandı" otomasyonuna Eşik'in "Şarja takıldı"
eylemini ekler. Eylem uygulamayı açmadan bildirimi gönderir
(`ios/Runner/EsikIntents.swift`). Kurulum rehberi her tetikleyici için
adımları gösterir ve otomasyon bir kez çalışınca adımı tamamlanmış sayar.

| Tetikleyici | Kestirmeler otomasyonu | Eylem |
|---|---|---|
| Şarja takınca | Şarj Cihazı → Bağlandı | Şarja takıldı |
| Uyku başlayınca | Uyku (ya da Odak → Uyku) → Başladığında | Uyku başladı |
| Alarmı durdurunca | Alarm → Durduruldu (iOS 17+) | Alarm durdu |
| Şarjdan çıkarınca | Şarj Cihazı → Bağlantısı Kesildi | Şarjdan çıkarıldı |
| Evden çıkınca | Wi‑Fi → ev ağı → Ayrıldığında | Evden çıkıldı |
| Kapıdaki etiket | NFC → etiketi tara | Kapı etiketi |

iOS'ta olmayanlar: sessize alınca / sessizden çıkarınca (sessiz düğmesi için
otomasyon yok) ve "sessizdeyken çal" (Apple'ın özel izni gerekir). Yedek saat
ve "Hepsi tamam" yerel bildirimlerle çalışır; gecikme saniyesinde gelir.
Deneme başlangıcı Anahtar Zinciri'nde tutulur, uygulama silinse de kalır.

## Senin yapacakların

### 1. Mac'te projeyi aç

```
git fetch && git checkout ios
flutter pub get
open ios/Runner.xcworkspace
```

Xcode → **Runner** hedefi → **Signing & Capabilities**:
- **Team**: Apple Developer hesabın
- **Bundle Identifier**: `com.ishakdas.threshold` (değiştirme; App Store
  Connect'teki uygulama buna bağlanacak)
- "Automatically manage signing" açık

### 2. Kendi iPhone'unda dene

iPhone'u Mac'e bağla, Xcode'da cihazı seç ve ▶︎ (Run). İlk kurulumda iPhone'da
**Ayarlar → Genel → VPN ve Aygıt Yönetimi**'nden geliştiriciye güven;
iOS 16+ için **Ayarlar → Gizlilik ve Güvenlik → Geliştirici Modu** açık
olmalı.

Denenecekler:
1. Kurulum rehberi: bildirim izni, ardından "Kestirmeler'i aç" ve otomasyonu
   kur. Otomasyon bir kez çalışınca adım kendiliğinden tamamlanmalı.
2. Şarja tak: aralık içindeysen bildirim gelmeli; "Hepsi tamam" uygulamayı
   açmadan kontrolü tamamlamalı.
3. Bildirime dokun: kontrol ekranı açılmalı.
4. Gecikme (ör. 1 dk) ve yedek saat.
5. "Bize yaz": Mail uygulaması açılmalı.

Bir şey çalışmazsa Xcode'un alt panelindeki hata mesajını bana gönder ya da
Mac'te Claude Code ile bu klasörde devam et.

### 3. App Store Connect'te uygulamayı oluştur

[appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Uygulamalar → + → Yeni Uygulama**
- Platform: iOS
- Ad: `Eşik: Doğru Anda Hatırlatıcı` (Play'deki ad; 30 karakter sınırı aynı)
- Birincil dil: Türkçe
- Paket kimliği: `com.ishakdas.threshold`
- SKU: `esik-ios`

**Sözleşmeler, Vergi ve Bankacılık**: "Ücretli Uygulamalar" sözleşmesini
kabul et, banka ve vergi bilgilerini gir. Bunlar olmadan uygulama içi satın
alma çalışmaz.

### 4. Eşik Plus ürünü

Uygulama → **Para Kazanma → Uygulama İçi Satın Almalar → +**
- Tür: **Tüketilmeyen** (Non-Consumable)
- Referans adı: Eşik Plus
- Ürün kimliği: `esik_plus` (uygulamadaki `plusProductId` ile aynı)
- Fiyat: Play'deki gibi (Türkiye 19,99 TL'ye en yakın kademe)
- Yerelleştirme: Türkçe, İngilizce, İspanyolca ad ve açıklama
  (`docs/play/console-formlari.md`'deki açıklama)
- İnceleme için ekran görüntüsü: Plus sayfasının görüntüsü

Deneme için **Kullanıcılar ve Erişim → Sandbox → Test Hesapları**'ndan bir
sandbox hesabı aç; iPhone'da **Ayarlar → App Store → Sandbox Hesabı** ile
gir. Satın alma ücretsiz olur.

### 5. TestFlight'a yükle

```
flutter build ipa --release
```

Çıkan `build/ios/ipa/*.ipa` dosyasını **Transporter** uygulamasıyla yükle
(ya da Xcode → Product → Archive → Distribute App). Birkaç dakika sonra
TestFlight'ta görünür; iPhone'daki TestFlight uygulamasıyla kur.

Şifreleme sorusu Info.plist'te cevaplı (`ITSAppUsesNonExemptEncryption =
false`), TestFlight yeniden sormaz.

### 6. Mağaza sayfası ve inceleme

- **Ekran görüntüleri**: iPhone 6,9" (1320×2868). Bunları üretebilirim;
  iOS ekranlarıyla (iOS tetikleyicileri, Kestirmeler adımı) yeniden çizmem
  gerekiyor, söylemen yeterli.
- **Metinler**: `docs/play/magaza.md`'deki açıklamalar; iOS'ta "sessiz mod"
  yerine "uyku" geçmeli, bunu da düzenleyebilirim.
- **Gizlilik politikası URL'si**: https://ishakdas.github.io/esik-gizlilik/
  (iPhone bölümü eklendi; `esik-gizlilik` deposundaki `index.md`'yi
  `docs/gizlilik.md` ile güncellemen gerekiyor).
- **Destek URL'si**: zorunlu; gizlilik sayfası ya da e-posta bağlantısı olan
  basit bir sayfa yeterli.
- **Uygulama Gizliliği**: "Veri toplamıyoruz" (Data Not Collected).
- **Yaş derecelendirmesi**: 4+ (soruların hepsi "Hayır").
- **İnceleme notu** (App Review Information → Notes):

> Eşik's triggers run through Shortcuts automations because iOS doesn't let
> apps observe charging, alarms or Wi‑Fi. To try it: Settings tab → "Check
> setup" → follow the steps, or in Shortcuts create an automation "Charger →
> Is Connected → Run Immediately" with the action "Eşik: Plugged in". The
> evening window is 22:00–02:00 by default; it can be turned off in Settings
> ("Only in this window"). The backup reminder and "Send test" also show the
> notification without any automation.
