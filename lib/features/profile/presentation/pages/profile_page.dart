import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/design_system_page.dart';
import '../../../../l10n/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary: the profile tab hosts the design system showcase in debug
    // builds until the real screen exists.
    if (kDebugMode) return const DesignSystemPage();
    final title = AppLocalizations.of(context)!.profileTitle;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
