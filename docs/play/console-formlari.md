# Play Console — form cevapları

Play Console → **Politika → Uygulama içeriği** altındaki formlar için.
Cevaplar uygulamanın bugünkü hâline göredir; yeni bir izin ya da ağ
bağlantısı eklenirse güncellenmeli.

## Uygulama içi ürün: Eşik Plus

Play Console → **Para kazanma → Ürünler → Tek seferlik ürünler → Tek seferlik ürün oluştur**

| Alan | Değer |
|---|---|
| Ürün kimliği | `esik_plus` (uygulamadaki `plusProductId` ile aynı olmalı, sonradan değişmez) |
| Ad | Eşik Plus |
| Açıklama | Birden fazla tetikleyici; sessiz mod, Wi‑Fi ve NFC tetikleyicileri; gün seçimi; sessizde titret/çal; geçmiş. Tek seferlik. |
| Satın alma seçeneği kimliği | `satin-al` (tür: Satın al; "Eski sürümlerle uyumlu", uygulama yalnızca ürün kimliğini kullanır) |
| Dijital içerik sınıfı | Dijital içerik (varsayılan); birden fazla adet satın alma kapalı |
| Tür | Tek seferlik, tüketilmeyen (non-consumable; uygulama satın alımı tüketmez) |

Fiyatlar KDV dahil, yani kullanıcının ödediği tutardır. Toplu düzenleme
("Set prices → Fiyatlandırmaları toplu olarak düzenle") girilen tutara KDV
ekler; KDV dahil fiyat her ülkenin satırındaki kalemle tek tek girilir.
Türkçe arayüzde ondalık ayırıcı virgüldür: `2.99` yazılırsa 299 olur.

| Ülke/bölge | Fiyat |
|---|---|
| Türkiye | **19,99 TL** |
| ABD (taban) | 2,99 $ — diğer ülkeler bundan Play'in çevirisiyle |
| Euro bölgesi (24 ülke: Almanya, Avusturya, Belçika, Bulgaristan, Estonya, Finlandiya, Fransa, Hollanda, Hırvatistan, Kıbrıs, Letonya, Litvanya, Lüksemburg, Malta, Monako, Portekiz, San Marino, Slovakya, Slovenya, Vatikan, Yunanistan, İrlanda, İspanya, İtalya) | 2,99 € |
| Birleşik Krallık | 2,49 £ |
| Meksika | 39 MXN |
| Brezilya | 9,90 BRL |
| Hindistan | 99 INR |
| Endonezya | 19.000 IDR |

Ürün sayfası, dahili teste bir AAB yüklendikten sonra açılır. Lisans testi:
Play Console → **Ayarlar → Lisans testi** altında `Esik-Dahili-Test` e-posta
listesi (`developerishak@gmail.com`) seçili; bu ayar geliştirici hesabındaki
tüm uygulamalara uygulanır. Listedeki hesaplar ödeme yapmadan satın alabilir.
Satın alma doğrulaması için gereken Base64 RSA ortak anahtarı: **Para
kazanma kurulumu → Lisanslama**.

Deneme süresi Play'de değil, uygulamada: ilk açılıştan itibaren 15 gün
(`plusTrialDays`, Android'de `EsikData.TRIAL_DAYS`).

## Gizlilik politikası

URL: https://ishakdas.github.io/esik-gizlilik/ (`ishakdas/esik-gizlilik` deposu, `docs/gizlilik.md` ile aynı tutulur).

## Reklamlar

**Hayır**, uygulama reklam içermiyor.

## Oturum açma bilgileri (eski adı: Uygulama erişimi)

"Uygulamanızda kısıtlanmış bölümler var mı?": **Hayır**. Hesap ve giriş yok;
temel özellikler ücretsiz.

"Evet" seçeneği tek seferlik ürünleri de sayıyor, ama o yol "tüm özelliklere
tam erişim sağlar" beyanı ister ve Play inceleyicileri ücretsiz denemeyi
kullanmıyor; 15 günlük deneme bu yüzden erişim yolu sayılmıyor.

## İçerik derecelendirmesi

E-posta: `developerishak@gmail.com`. Anket kategorisi: **Diğer Tüm Uygulama
Türleri** (oyun, sosyal ya da iletişim değil). IARC Kullanım Şartları kabul
edilir.

| Soru | Cevap |
|---|---|
| İndirilen pakette derecelendirmeyle ilgili içerik (cinsellik, şiddet, dil) | Hayır |
| Kullanıcılar birbiriyle etkileşim kurabiliyor / içerik paylaşabiliyor mu | Hayır |
| Pakette olmayan, uygulamadan erişilen çevrimiçi içerik | Hayır |
| Yaş kısıtlamalı ürün/etkinlik (sigara, alkol, silah, kumar) tanıtımı | Hayır |
| Kullanıcının tam konumunu paylaşıyor mu | Hayır |
| Dijital ürün satın alımı | **Evet** (Eşik Plus) |
| Bunlar ganimet kutusu gibi içeriği bilinmeyen alımlar mı | Hayır |
| Nakit ödül, hediye kartı, kripto, NFT | Hayır |
| Web tarayıcısı ya da arama motoru | Hayır |
| Esas olarak haber ya da eğitim ürünü | Hayır |

Sonuç: **3+ / Herkes** (PEGI 3, ESRB Tüm yaşlar, USK Tüm yaşlar, IARC 3+);
yalnızca Brezilya (ClassInd) **14+**. Hepsinde "Uygulama İçi Satın Alma
İşlemleri" etiketi var.

## Hedef kitle

Hedef yaş grubu: **18 yaş ve üstü**. 13 yaş altını seçmemek gerekir; Aile
Politikası'nın ek koşulları devreye girer. 18+ seçilince "çocukların ilgisini
çekebilir mi" sorusu gelmiyor. Form, "Oturum açma bilgileri" tamamlanmadan
açılmaz.

## Veri güvenliği

| Soru | Cevap |
|---|---|
| Uygulamanız gerekli kullanıcı veri türlerinden herhangi birini topluyor veya paylaşıyor mu? | **Hayır** |

Satın alma Google Play üzerinden yapılır; ödeme bilgisi uygulamaya hiç
gelmez. Uygulama yalnızca Play'den "Plus satın alındı mı" bilgisini sorar ve
cihazda saklar; bu bilgi uygulamadan dışarı çıkmaz. Bu yüzden "Satın alma
geçmişi" beyan edilmedi. Form, hedef kitle tamamlanmadan kaydedilmez.

CI her derlemede APK'nın izin listesini yazdırır ("APK izinleri" adımı).

Gerekçe: Sürüm APK'sındaki `INTERNET` izni Google Play ödeme kütüphanesinden
geliyor ve yalnızca Play satın alma doğrulaması için kullanılıyor; Eşik'in
kendi sunucusu ya da ağ isteği yok. Listeler, ayarlar ve geçmiş yalnızca cihazda,
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

## Reklam Kimliği

"Uygulamanız reklam kimliği kullanıyor mu?": **Hayır**. APK'da
`com.google.android.gms.permission.AD_ID` izni yok.

## Haber uygulaması / COVID / finans / sağlık / devlet

Hepsi **Hayır**. Finans formunda "Uygulamamda finans ile ilgili özellik
sağlanmıyor", sağlık formunda "Uygulamamda sağlık özellikleri yok" işaretli;
resmi kurum uygulaması sorusu Hayır.
