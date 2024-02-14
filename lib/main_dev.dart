import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upload_manager/app/modules/home/JobLabel.dart';

import '/flavors/build_config.dart';
import '/flavors/env_config.dart';
import '/flavors/environment.dart';
import 'app/my_app.dart';
import 'data/end_points.dart';

void main()  {
  EnvConfig devConfig = EnvConfig(
    appName: "Upload Manager Dev",
    baseUrl: baseUrlApi,
    shouldCollectCrashLog: true,
  );

  BuildConfig.instantiate(
    envType: Environment.DEVELOPMENT,
    envConfig: devConfig,
  );

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
