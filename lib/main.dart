import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // İlk kare hiçbir şey beklemeden çizilir; ayarlar EsikBootstrap içinde yüklenir.
  runApp(const EsikBootstrap());
}
