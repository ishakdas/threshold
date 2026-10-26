# Play Console — form cevapları

Play Console → **Politika → Uygulama içeriği** altındaki formlar için.
Cevaplar uygulamanın bugünkü hâline göredir; yeni bir izin ya da ağ
bağlantısı eklenirse güncellenmeli.

## Uygulama içi ürün: Eşik Plus

Play Console → **Para kazanma → Ürünler → Uygulama içi ürünler → Ürün oluştur**

| Alan | Değer |
|---|---|
| Ürün kimliği | `esik_plus` (uygulamadaki `plusProductId` ile aynı olmalı, sonradan değişmez) |
| Ad | Eşik Plus |
| Açıklama | Birden fazla tetikleyici, Wi‑Fi ve NFC, gün seçimi, sessizde titret/çal, geçmiş. Tek seferlik. |
| Fiyat | Türkiye: **49 TL**. Diğer ülkeler için Play'in otomatik çevirisi ya da elle (ör. 2,99 $) |
| Tür | Tek seferlik, tüketilmeyen (non-consumable) |

Ürün, uygulamanın Play'e yüklenmiş bir sürümü olmadan oluşturulamaz; önce
dahili teste bir AAB yüklenir. Test için Play Console → **Ayarlar → Lisans
testi** altına test hesabının e-postası eklenir; bu hesaplar ödeme yapmadan
satın alabilir.

Deneme süresi Play'de değil, uygulamada: ilk açılıştan itibaren 15 gün
(`plusTrialDays`, Android'de `EsikData.TRIAL_DAYS`).

## Gizlilik politikası

URL: `docs/gizlilik.md` yayımlandığı adres (GitHub Pages ya da benzeri).

## Reklamlar

**Hayır**, uygulama reklam içermiyor.

## Uygulama erişimi

**Tüm işlevler özel erişim gerektirmeden kullanılabilir.** (Hesap, giriş yok.)

## İçerik derecelendirmesi

Anket kategorisi: **Yardımcı program, verimlilik, iletişim veya diğer**

| Soru | Cevap |
|---|---|
| Şiddet, cinsellik, küfür, uyuşturucu, kumar | Hayır |
| Kullanıcılar birbiriyle iletişim kurabiliyor mu / içerik paylaşabiliyor mu | Hayır |
| Kullanıcının konumunu paylaşıyor mu | Hayır |
| Dijital ürün satın alımı | Hayır |

Beklenen sonuç: **3+ / Herkes**.

## Hedef kitle

Hedef yaş grubu: **18 ve üzeri** (ister **13+** de seçilebilir). 13 yaş
altını seçmemek gerekir; Aile Politikası'nın ek koşulları devreye girer.
"Uygulama çocukların ilgisini çekebilir mi?": **Hayır**.

## Veri güvenliği

| Soru | Cevap |
|---|---|
| Uygulamanız gerekli kullanıcı veri türlerinden herhangi birini topluyor veya paylaşıyor mu? | **Hayır** |

Satın alma Google Play üzerinden yapılır; ödeme bilgisi uygulamaya hiç
gelmez. Uygulama yalnızca Play'den "Plus satın alındı mı" bilgisini sorar ve
cihazda saklar; bu bilgi uygulamadan dışarı çıkmaz. Bunun "Satın alma
geçmişi" beyanı gerektirip gerektirmediği, formu doldururken Play Console'daki
güncel açıklamaya göre kontrol edilmeli.

CI her derlemede APK'nın izin listesini yazdırır ("APK izinleri" adımı);
internet izni girerse uyarı verir.

Gerekçe: Sürüm APK'sında `INTERNET` izni yok (yalnızca debug/profile
manifest'lerinde var). Listeler, ayarlar ve geçmiş yalnızca cihazda,
uygulamanın özel depolamasında (SharedPreferences) tutuluyor. Şarj, ses
kademesi, sıradaki alarm ve ağ türü yalnızca o an karar için okunuyor,
saklanmıyor ve cihazdan çıkmıyor.

"Hayır" seçilince şifreleme ve silme talebi soruları sorulmaz.

## Hassas izinler

Play Console'da ayrı beyan formu gerektiren izin **yok**:

| İzin | Durum |
|---|---|
| `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` | Kullanılmıyor (yedek saat `setAndAllowWhileIdle`) |
| Ön plan servisi (`FOREGROUND_SERVICE_*`) | Kullanılmıyor |
| Konum, SMS, arama kaydı, tüm dosyalara erişim | Kullanılmıyor |
| `QUERY_ALL_PACKAGES` | Kullanılmıyor |

Dikkat edilecek tek izin **`REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`**. Beyan
formu yok ama inceleme sırasında Google'ın kabul edilebilir kullanım
listesine uyması beklenir. Eşik'in gerekçesi:

> Eşik, kullanıcının seçtiği davranışlar (şarja takma, ses kademesini
> değiştirme, alarmın çalması, Wi‑Fi'dan çıkma) gerçekleştiğinde, telefon
> uyurken de kontrol listesini göstermek zorundadır. Pil optimizasyonu
> açıkken Samsung ve diğer üreticiler uygulamayı uyutup bu tetikleyicileri
> saatlerce geciktiriyor; bu da uygulamanın temel işlevini bozuyor. İzin
> yalnızca kurulum rehberinde, kullanıcı istediğinde soruluyor ve
> reddedilirse uygulama yedek saatle çalışmaya devam ediyor.

Reddedilirse yapılacak: izni kaldırıp pil adımını "uygulama ayarları +
Pil → Kısıtlamasız ipucu" yoluna döndürmek (`MainActivity.openBatterySettings`).

## Haber uygulaması / COVID / finans / sağlık / devlet

Hepsi **Hayır**.
