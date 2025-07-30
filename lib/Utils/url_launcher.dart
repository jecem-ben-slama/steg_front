// You might put this in a utility file or directly in your widget
import 'package:url_launcher/url_launcher.dart';

Future<void> downloadPdf(String? pdfUrl) async {
  if (pdfUrl == null || pdfUrl.isEmpty) {
    // Handle cases where there's no PDF URL
    print('No PDF URL available for download.');
    // Optionally show a SnackBar or Toast to the user
    return;
  }

  final Uri url = Uri.parse(pdfUrl);
  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    ); // For web, this opens in a new tab
  } else {
    print('Could not launch $url');
    // Optionally show an error message
  }
}
