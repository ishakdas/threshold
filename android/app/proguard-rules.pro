# Sürüm derlemesinde R8 kodu küçültür. Platform kanalı üzerinden yalnızca
# yansımayla (reflection) erişilen eklenti sınıfları silinmesin.

# shared_preferences (eski API + DataStore tabanlı yeni API)
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class androidx.datastore.** { *; }

# Eklentilerin otomatik kaydı
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
