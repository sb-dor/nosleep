import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  Future<void> openUrl(final String path) async {
    final url = Uri.parse(path);
    await launchUrl(url);
  }
}
