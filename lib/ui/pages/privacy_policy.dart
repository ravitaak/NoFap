import 'package:flutter/material.dart';
import 'package:nofap_reboot/l10n/generated/i18n/app_localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _controller.loadFlutterAsset("assets/privacy.html");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(AppLocalizations.of(context)!.privacy_policy),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
