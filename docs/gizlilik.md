# Eşik — Gizlilik Politikası

*Son güncelleme: 3 Kasım 2026*

Eşik, akşam ve sabah kontrol listelerini doğru anda hatırlatan bir
uygulamadır. Bu politika, uygulamanın hangi bilgileri nasıl kullandığını
anlatır.

## Kısaca

- Listelerin, ayarların, geçmişin ve "Kilitledim mi?" fotoğrafların yalnızca
  telefonunda durur; hiçbir sunucuya gönderilmez.
- Telefondan çıkan yalnızca iki şey var:
  - **Deneme süresi kaydı (Android):** Ücretsiz denemenin, uygulama silinip
    yeniden kurulunca baştan başlamaması için telefonun uygulamaya özel
    kimliğinin tek yönlü özeti (geri çevrilemez) ve denemenin başladığı an
    Eşik'in sunucusunda saklanır. Bunun dışında hiçbir şey saklanmaz.
  - **Hava durumu (isteğe bağlı):** Şehir seçersen, tahmin için yalnızca o
    şehrin koordinatları Open-Meteo'ya (open-meteo.com) gönderilir. Konum
    iznin istenmez; şehir seçmezsen hiçbir şey gönderilmez.
- Hesap, reklam, analitik ya da takip aracı yoktur.
- Eşik Plus satın alımı Google Play üzerinden yapılır; ödeme bilgilerin
  Eşik'e hiç ulaşmaz. Eşik yalnızca Play'den Plus'ın satın alınıp
  alınmadığını öğrenir ve bunu telefonunda saklar.

## Telefonunda saklananlar

Aşağıdakiler yalnızca senin telefonunda, Eşik'in kendi depolama alanında
durur ve uygulamayı kaldırdığında silinir:

- Kontrol listelerin (madde adları ve ikonları)
- Eşik ayarların: seçtiğin tetikleyiciler, günler, saat aralıkları, yedek saat
- Kontrol geçmişin: hangi gün hangi kontrolü ne zaman tamamladığın (en fazla 400 gün)
- "Fotoğrafla kontrol" açık maddelerde çektiğin fotoğraflar (14 gün sonra silinir)
- Hava durumu için seçtiğin şehir ve son tahmin

## İzinler ve neden gerektikleri

| İzin | Neden |
|---|---|
| Bildirimler | Eşik geldiğinde kontrol listeni göstermek için. |
| Açılışta çalışma | Telefon yeniden başlayınca hatırlatmaları yeniden kurmak için. |
| Pil optimizasyonundan muafiyet (isteğe bağlı) | Telefon uyurken tetikleyicilerin kaçmaması için. |
| NFC (isteğe bağlı) | Kapıdaki etikete Eşik'in bağlantısını yazmak ve okumak için. |
| Titreşim | "Telefon sessizdeyken titret / çal" seçeneği için. |
| Kamera (isteğe bağlı) | "Fotoğrafla kontrol" açık maddeyi işaretlerken fotoğraf çekmek için. |
| İnternet | Deneme süresi kaydı, hava tahmini ve satın alma için. |
| Ağ ve Wi‑Fi durumu | "İnterneti kapatınca" ve "Wi‑Fi'dan çıkınca" tetikleyicileri için. |

Eşik; şarj durumunu, telefonun ses kademesini (sesli / titreşim / sessiz),
sıradaki alarmın saatini ve Wi‑Fi ile mobil veri arasında geçişi yalnızca o
an tetikleyiciye karar vermek için okur. Bunlar kaydedilmez ve telefondan
çıkmaz. Wi‑Fi ağının adı ve konumun okunmaz.

### iPhone'da

iPhone'da Eşik bu olayları kendisi okumaz. Şarja takma, alarmın durması,
Wi‑Fi'dan ayrılma, NFC etiketi ya da uyku gibi anları senin Kestirmeler
uygulamasında kurduğun otomasyonlar Eşik'e bildirir; Eşik yalnızca hangi
anın olduğunu öğrenir. Ücretsiz denemenin başlangıç tarihi, uygulama silinip
yeniden kurulduğunda sıfırlanmasın diye telefonun Anahtar Zinciri'nde
tutulur; bu tarih de telefondan çıkmaz. Eşik Plus satın alımı App Store
üzerinden yapılır; ödeme bilgilerin Eşik'e ulaşmaz.

## Çocuklar

Eşik çocuklara yönelik değildir ve kimseden bilgi toplamaz.

## Değişiklikler

Bu politika değişirse güncel hâli bu sayfada yayımlanır.

## İletişim

Sorular için: developerishak@gmail.com

---

# Eşik — Privacy Policy (English)

*Last updated: 30 October 2026*

Eşik reminds you of your evening and morning checklists at the right moment.

- Your lists, settings, history and "Did I lock it?" photos stay on your
  phone and are never uploaded.
- Only two things leave the phone: (1) on Android, a one‑way hash of the
  app‑specific device ID and the trial start time, stored on Eşik's server so
  the free trial doesn't restart after reinstalling; (2) if you choose a city
  for the weather, only that city's coordinates are sent to Open-Meteo
  (open-meteo.com). No location permission is requested.
- There are no accounts, ads, analytics or third‑party trackers.
- Eşik Plus is purchased through Google Play; your payment details never
  reach Eşik. The app only asks Google Play whether Plus was purchased and
  stores that on your phone.

Your checklists, settings and check history are stored only on your phone,
in the app's private storage, and are deleted when you uninstall the app.

Eşik reads the charging state, the phone's sound mode, the time of the next
alarm and the switch between Wi‑Fi and mobile data only to decide, at that
moment, whether a trigger happened. None of this is stored or leaves the
phone. Wi‑Fi network names and location are never read.

On iPhone, Eşik does not read these events itself: automations you set up in
the Shortcuts app tell Eşik which moment happened. The free trial's start date
is kept in the phone's Keychain so it survives reinstalling the app; it never
leaves the phone. Eşik Plus is purchased through the App Store.

Permissions: notifications (to show your checklist), run at startup (to
restore reminders after a reboot), battery optimization exemption (optional,
so triggers are not missed while the phone sleeps), NFC (optional, to write
and read the door tag), vibration (for the "when silent, vibrate / ring"
option).

Contact: developerishak@gmail.com
