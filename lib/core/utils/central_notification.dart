import 'dart:async';
import 'package:flutter/material.dart';

void showCentralNotification(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });

      return _CentralNotificationDialog(message: message, isError: isError);
    },
  );
}

class _CentralNotificationDialog extends StatelessWidget {
  final String message;
  final bool isError;

  const _CentralNotificationDialog({
    required this.message,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isError ? Colors.red.shade400 : Colors.green.shade400,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
