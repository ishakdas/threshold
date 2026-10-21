# Sürüm derlemesinde R8 kodu küçültür. Platform kanalı üzerinden yalnızca
# yansımayla (reflection) erişilen eklenti sınıfları silinmesin.

# shared_preferences (eski API + DataStore tabanlı yeni API).
# Not: 2.5.x'in JNI hatasını bu kural çözmedi; çözüm pubspec.yaml'daki sabitleme.
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class androidx.datastore.** { *; }

# Eklentilerin otomatik kaydı
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
