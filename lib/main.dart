import 'package:flutter/material.dart';

import 'infrastructure/di/service_locator.dart';
import 'presentation/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator.instance.initialize();
  runApp(const BggMeepleApp());
}
