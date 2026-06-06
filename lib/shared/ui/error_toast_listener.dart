import 'package:flutter/material.dart';
import 'package:developer_task/shared/ui/app_toast.dart';

/// Listens to a provider [errorMessage] and shows a red [AppToast] once per change.
class ErrorToastListener extends StatefulWidget {
  const ErrorToastListener({
    super.key,
    required this.errorMessage,
    required this.child,
  });

  final String? errorMessage;
  final Widget child;

  @override
  State<ErrorToastListener> createState() => _ErrorToastListenerState();
}

class _ErrorToastListenerState extends State<ErrorToastListener> {
  String? _lastShown;

  @override
  void initState() {
    super.initState();
    _showIfNeeded(widget.errorMessage);
  }

  @override
  void didUpdateWidget(ErrorToastListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != oldWidget.errorMessage) {
      _showIfNeeded(widget.errorMessage);
    }
  }

  void _showIfNeeded(String? message) {
    if (message == null) {
      _lastShown = null;
      return;
    }
    if (message == _lastShown) return;
    _lastShown = message;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppToast.error(context, message);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
