import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class PigeondexPage extends StatelessWidget {
  const PigeondexPage({super.key});

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context)!.pigeondexTitle;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
