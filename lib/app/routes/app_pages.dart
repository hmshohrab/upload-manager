import 'package:get/get_navigation/src/routes/get_route.dart';

import '../modules/UploadHistory/bindings/upload_history_binding.dart';
import '../modules/UploadHistory/views/upload_history_view.dart';
import '/app/modules/home/bindings/home_binding.dart';
import '/app/modules/home/views/home_view.dart';
import '/app/modules/main/bindings/main_binding.dart';
import '/app/modules/main/views/main_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.MAIN;

  static final routes = [
    GetPage(
      name: _Paths.MAIN,
      page: () => MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.UPLOAD_HISTORY,
      page: () =>   UploadHistoryView(),
      binding: UploadHistoryBinding(),
    ),
  ];
}
