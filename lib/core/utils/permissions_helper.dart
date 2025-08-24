import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;

    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    return status.isGranted;
  }

  static Future<bool> requestManageExternalStorage() async {
    var status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }

    return status.isGranted;
  }
}
