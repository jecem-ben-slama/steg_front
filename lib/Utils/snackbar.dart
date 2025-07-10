import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:pfa/Utils/Consts/style.dart';

//* success
void showSuccessSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,

    content: AwesomeSnackbarContent(
      title: 'Oh hey!',
      message: message,
      contentType: ContentType.success,
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

//* failure
void showFailureSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,

    content: AwesomeSnackbarContent(
      color: MyColors.red,
      title: 'Oh Snap!',
      message: message,
      contentType: ContentType.failure,
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

//* warning
void showWarningSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,

    content: AwesomeSnackbarContent(
      title: 'Warning!',
      message: message,
      contentType: ContentType.warning,
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

//* help
void showHelpSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,

    content: AwesomeSnackbarContent(
      title: 'Hey There!',
      message: message,
      contentType: ContentType.help, // For informational messages
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
