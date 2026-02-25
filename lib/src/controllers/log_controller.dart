import 'package:get/get.dart';
import '../services/log_service.dart';
import '../models/log_model.dart';

class LogController extends GetxController {
  final LogService service;

  LogController(this.service);

  RxList<AppLogModel> logs = <AppLogModel>[].obs;

  @override
  void onInit() {
    logs.assignAll(service.logs);
    super.onInit();
  }
}
