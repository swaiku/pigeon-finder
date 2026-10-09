import 'package:flutter/material.dart';

import '../widgets/pf_avatar.dart';
import '../widgets/pf_bottom_nav_bar.dart';
import '../widgets/pf_button.dart';
import '../widgets/pf_card.dart';
import '../widgets/pf_chip.dart';
import '../widgets/pf_empty_state.dart';
import '../widgets/pf_error_state.dart';
import '../widgets/pf_image_placeholder.dart';
import '../widgets/pf_like_button.dart';
import '../widgets/pf_loading_indicator.dart';
import '../widgets/pf_progress_bar.dart';
import '../widgets/pf_ranking_row.dart';
import '../widgets/pf_segmented_control.dart';
import '../widgets/pf_text_field.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Debug-only page showing every design system token and component so the
/// result can be checked visually. Not part of the app's navigation.
class DesignSystemPage extends StatefulWidget {
  const DesignSystemPage({super.key});

  @override
  State<DesignSystemPage> createState() => _DesignSystemPageState();
}

class _DesignSystemPageState extends State<DesignSystemPage> {
  final _emailController = TextEditingController();
  int _scopeIndex = 1;
  int _navIndex = 0;
  bool _liked = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design system')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        children: [
          const _Section(title: 'Couleurs', child: _ColorPalette()),
          const _Section(title: 'Typographie', child: _TypeScale()),
          const _Section(title: 'Rayons & ombres', child: _RadiiAndShadows()),
          _Section(
            title: 'Boutons',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PfButton(label: 'Publier sur la carte', onPressed: () {}),
                const SizedBox(height: AppSpacing.sm),
                PfButton(
                  label: 'Reprendre la photo',
                  variant: PfButtonVariant.secondary,
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                PfButton(
                  label: "Contester l'IA",
                  variant: PfButtonVariant.outline,
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                PfLikeButton(
                  label: _liked ? 'Roucoule · 58' : 'Roucoule · 57',
                  selected: _liked,
                  onTap: () => setState(() => _liked = !_liked),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Champ de texte',
            child: PfTextField(
              controller: _emailController,
              hintText: 'toi@exemple.fr',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          _Section(
            title: 'Carte',
            child: PfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Roucouleur · niv. 7',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Contenu générique affiché dans une PfCard.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          _Section(
            title: 'Étiquettes & badges',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: const [
                PfStatusChip(
                  label: 'Pigeon biset confirmé · 96 %',
                  tone: PfChipTone.success,
                ),
                PfStatusChip(
                  label: 'Goéland argenté · 82 %',
                  tone: PfChipTone.danger,
                ),
                PfStatusChip(
                  label: '2 signalement(s)',
                  tone: PfChipTone.warning,
                ),
                PfStatusChip(label: 'Expire dans 18 h', tone: PfChipTone.dark),
                PfStatusChip(label: 'Badge obtenu', tone: PfChipTone.dark),
                PfStatusChip(label: 'Badge verrouillé', filled: false),
                PfCountBadge(label: '×3'),
              ],
            ),
          ),
          _Section(
            title: 'Contrôle segmenté',
            child: PfSegmentedControl(
              labels: const ['Quartier', 'Paris', 'Monde'],
              selectedIndex: _scopeIndex,
              onChanged: (i) => setState(() => _scopeIndex = i),
            ),
          ),
          _Section(
            title: "Barre de progression",
            child: const PfProgressBar(value: 0.62),
          ),
          _Section(
            title: 'Avatar',
            child: Row(
              children: const [
                PfAvatar(initial: 'C'),
                SizedBox(width: AppSpacing.sm),
                PfAvatar(initial: 'P', size: 54),
              ],
            ),
          ),
          _Section(
            title: 'Ligne de classement',
            child: Column(
              children: [
                const PfRankingRow(
                  rank: '4',
                  avatarInitial: 'P',
                  title: 'pigeon.parisien',
                  subtitle: 'Roucouleur · 1 702 pigeons',
                  trailing: '12 040 pts',
                ),
                const SizedBox(height: AppSpacing.sm),
                const PfRankingRow(
                  rank: '9',
                  avatarInitial: 'C',
                  title: 'Toi',
                  trailing: '1 240 pts',
                  highlighted: true,
                ),
              ],
            ),
          ),
          _Section(
            title: 'Placeholder image',
            child: const SizedBox(
              height: 120,
              width: 120,
              child: PfImagePlaceholder(),
            ),
          ),
          const _Section(
            title: 'État vide',
            child: PfEmptyState(
              message:
                  'Aucun pigeon actif. Tes photos restent 24 h sur la carte.',
            ),
          ),
          const _Section(
            title: 'Chargement',
            child: PfLoadingIndicator(message: "L'IA inspecte ton oiseau…"),
          ),
          _Section(
            title: 'Erreur',
            child: PfErrorState(
              message: "Ça, ce n'est pas un pigeon.",
              actionLabel: 'Reprendre',
              onAction: () {},
            ),
          ),
          _Section(
            title: 'Navigation basse',
            child: PfBottomNavBar(
              items: const [
                PfNavItem(icon: Icons.map_outlined, label: 'Carte'),
                PfNavItem(icon: Icons.grid_view_outlined, label: 'Pigeondex'),
                PfNavItem(
                  icon: Icons.emoji_events_outlined,
                  label: 'Classement',
                ),
                PfNavItem(icon: Icons.person_outline, label: 'Profil'),
              ],
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
              centerIcon: Icons.camera_alt_outlined,
              onCenterTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _ColorPalette extends StatelessWidget {
  const _ColorPalette();

  static const _swatches = [
    (name: 'Nuit', color: AppColors.night),
    (name: 'Épingle', color: AppColors.pin),
    (name: 'Col irisé', color: AppColors.iridescent),
    (name: 'Plume violette', color: AppColors.feather),
    (name: 'Ardoise', color: AppColors.slate),
    (name: 'Grain', color: AppColors.grain),
    (name: 'Seine', color: AppColors.river),
    (name: 'Parc', color: AppColors.park),
    (name: 'Pavé', color: AppColors.pavement),
    (name: 'Crème', color: AppColors.cream),
    (name: 'Papier', color: AppColors.paper),
    (name: 'Trait', color: AppColors.trait),
    (name: 'Brume', color: AppColors.mist),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final swatch in _swatches)
          SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: swatch.color,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                    border: Border.all(color: AppColors.divider),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  swatch.name,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  '#${swatch.color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TypeScale extends StatelessWidget {
  const _TypeScale();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rows = <(String, TextStyle?)>[
      ('displayLarge', textTheme.displayLarge),
      ('displayMedium', textTheme.displayMedium),
      ('displaySmall', textTheme.displaySmall),
      ('headlineLarge', textTheme.headlineLarge),
      ('headlineMedium', textTheme.headlineMedium),
      ('headlineSmall', textTheme.headlineSmall),
      ('titleLarge', textTheme.titleLarge),
      ('titleMedium', textTheme.titleMedium),
      ('titleSmall', textTheme.titleSmall),
      ('bodyLarge', textTheme.bodyLarge),
      ('bodyMedium', textTheme.bodyMedium),
      ('bodySmall', textTheme.bodySmall),
      ('labelLarge', textTheme.labelLarge),
      ('labelMedium', textTheme.labelMedium),
      ('labelSmall', textTheme.labelSmall),
    ];

    return PfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(row.$1, style: textTheme.labelSmall),
                  ),
                  Expanded(child: Text('Pigeon Finder', style: row.$2)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RadiiAndShadows extends StatelessWidget {
  const _RadiiAndShadows();

  static const _radii = [
    (label: 'vignette', value: AppSpacing.radiusThumbnail),
    (label: 'bouton', value: AppSpacing.radiusButton),
    (label: 'carte', value: AppSpacing.radiusCard),
    (label: 'panneau', value: AppSpacing.radiusPanel),
    (label: 'feuille', value: AppSpacing.radiusSheet),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.md,
      children: [
        for (final radius in _radii)
          Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(radius.value),
                  boxShadow: AppSpacing.shadowFloating,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${radius.value.toInt()} · ${radius.label}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
      ],
    );
  }
}
