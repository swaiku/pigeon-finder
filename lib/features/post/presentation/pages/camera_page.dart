import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_back_button.dart';
import '../../../../core/widgets/pf_button.dart';
import '../../../../core/widgets/pf_error_state.dart';
import '../../../../core/widgets/pf_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/new_post.dart';
import '../bloc/post_cubit.dart';

/// Why the viewfinder cannot be shown.
enum _CameraIssue { denied, unavailable }

/// New post: a full-screen viewfinder, then a review step with an optional
/// description before publishing. Closes with `true` once published.
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  /// Codes of `CameraException` meaning the user refused the permission.
  static const _deniedCodes = {
    'CameraAccessDenied',
    'CameraAccessDeniedWithoutPrompt',
    'CameraAccessRestricted',
  };

  final _description = TextEditingController();
  CameraController? _controller;
  _CameraIssue? _issue;
  XFile? _photo;
  CameraLensDirection _lens = CameraLensDirection.back;
  bool _capturing = false;

  /// The camera being opened, so that only one open runs at a time.
  Future<void>? _opening;

  /// Bumped when the app goes to the background: an open still running then
  /// is stale, and closes its camera instead of keeping it.
  int _generation = 0;

  /// The app went inactive mid-capture: release the camera once it is done.
  bool _releaseAfterCapture = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initCamera());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller?.dispose());
    _description.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The camera is a shared resource: release it while in the background,
    // and reopen it on return (the user may have granted it in the settings).
    switch (state) {
      case AppLifecycleState.inactive:
        // Also sent by the permission dialog: an open still running then is
        // kept, it is waiting for the user's answer.
        if (_capturing) {
          _releaseAfterCapture = true;
        } else {
          _releaseCamera();
        }
      case AppLifecycleState.paused:
        _generation++;
      case AppLifecycleState.resumed:
        _releaseAfterCapture = false;
        if (_controller == null && _photo == null) unawaited(_initCamera());
      case AppLifecycleState.detached || AppLifecycleState.hidden:
        break;
    }
  }

  void _releaseCamera() {
    final controller = _controller;
    if (controller == null) return;
    if (mounted) setState(() => _controller = null);
    unawaited(controller.dispose());
  }

  /// Opens the camera unless it is already open, waiting for an open
  /// already running instead of starting a second one on the same lens.
  Future<void> _initCamera() async {
    for (var running = _opening; running != null; running = _opening) {
      await running;
    }
    if (!mounted || _controller != null || _photo != null) return;
    final opening = _open();
    _opening = opening;
    try {
      await opening;
    } finally {
      if (identical(_opening, opening)) _opening = null;
    }
  }

  Future<void> _open() async {
    final generation = _generation;
    setState(() => _issue = null);
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _issue = _CameraIssue.unavailable);
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == _lens,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        // ~720p JPEGs stay well below the 5 MB limit of the photos bucket.
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted || generation != _generation) {
        // Left the page or went to the background meanwhile: resumed reopens.
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _issue = null;
      });
    } on CameraException catch (e) {
      debugPrint('Camera failed: ${e.code} ${e.description}');
      if (!mounted) return;
      setState(
        () => _issue = _deniedCodes.contains(e.code)
            ? _CameraIssue.denied
            : _CameraIssue.unavailable,
      );
    } on Exception catch (e) {
      // e.g. no camera plugin on this platform.
      debugPrint('Camera failed: $e');
      if (mounted) setState(() => _issue = _CameraIssue.unavailable);
    }
  }

  Future<void> _takePhoto() async {
    final controller = _controller;
    if (controller == null || _capturing) return;
    final failed = AppLocalizations.of(context)!.cameraCaptureFailed;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _capturing = true);
    try {
      // Kept as soon as it is taken: a failure afterwards must not lose it.
      final photo = await controller.takePicture();
      if (mounted) setState(() => _photo = photo);
      try {
        await controller.pausePreview();
      } on CameraException catch (e) {
        debugPrint('Pausing the preview failed: ${e.code}');
      }
    } on CameraException catch (e) {
      debugPrint('Capture failed: ${e.code} ${e.description}');
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      if (mounted) setState(() => _capturing = false);
      if (_releaseAfterCapture) {
        _releaseAfterCapture = false;
        _releaseCamera();
      }
    }
  }

  Future<void> _flip() async {
    final controller = _controller;
    if (controller == null || _capturing) return;
    setState(() => _controller = null);
    await controller.dispose();
    _lens = _lens == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    await _initCamera();
  }

  Future<void> _retake() async {
    context.read<PostCubit>().dismissError();
    setState(() => _photo = null);
    final controller = _controller;
    if (controller == null) {
      await _initCamera();
    } else {
      await controller.resumePreview();
    }
  }

  Future<void> _publish() async {
    final photo = _photo;
    if (photo == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final published = AppLocalizations.of(context)!.postPublished;
    final ok = await context.read<PostCubit>().publish(
      photoPath: photo.path,
      description: _description.text,
    );
    if (!ok || !mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(published)));
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photo;
    if (photo != null) {
      return _ReviewView(
        photo: photo,
        description: _description,
        onRetake: _retake,
        onPublish: _publish,
      );
    }
    final issue = _issue;
    if (issue != null) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: AppSpacing.lg,
                left: AppSpacing.lg,
                child: PfBackButton(),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: PfErrorState(
                    message: switch (issue) {
                      _CameraIssue.denied => l10n.cameraDenied,
                      _CameraIssue.unavailable => l10n.cameraUnavailable,
                    },
                    actionLabel: l10n.retry,
                    onAction: _initCamera,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return _ViewfinderView(
      controller: _controller,
      capturing: _capturing,
      onShutter: _takePhoto,
      onFlip: _flip,
    );
  }
}

class const _ViewfinderView({
  required final CameraController? controller,
  required final bool capturing,
  required final VoidCallback onShutter,
  required final VoidCallback onFlip,
}) extends StatelessWidget {
  static const _shutterSize = 82.0;
  static const _shutterRing = 5.0;
  static const _sideSize = 48.0;
  static const _frameInset = 44.0;
  static const _frameHeight = 374.0;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    final ready = controller != null && controller.value.isInitialized;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.viewfinder,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (ready)
            // shortcut: assumes portrait, the app is locked to it.
            ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: 100,
                  height: 100 * controller.value.aspectRatio,
                  child: CameraPreview(controller),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.paper),
            ),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _frameInset),
              child: SizedBox(
                height: _frameHeight,
                width: double.infinity,
                child: CustomPaint(painter: _FramePainter()),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.roomy,
                  AppSpacing.md,
                  0,
                  0,
                ),
                child: _GlassButton(
                  icon: Icons.close_rounded,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  size: 42,
                  onPressed: context.pop,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  0,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                      ),
                      child: Text(
                        l10n.cameraHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: AppColors.paper),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Where the design shows the last photo taken.
                        const SizedBox(width: _sideSize),
                        Semantics(
                          button: true,
                          label: l10n.cameraShutter,
                          child: GestureDetector(
                            onTap: ready && !capturing ? onShutter : null,
                            child: Container(
                              width: _shutterSize,
                              height: _shutterSize,
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.paper,
                                  width: _shutterRing,
                                ),
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: capturing
                                      ? AppColors.mutedText
                                      : AppColors.pin,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _GlassButton(
                          icon: Icons.sync_rounded,
                          tooltip: l10n.cameraFlip,
                          size: _sideSize,
                          onPressed: ready && !capturing ? onFlip : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Round button, [AppColors.paper] at 14 % over the viewfinder.
class const _GlassButton({
  required final IconData icon,
  required final String tooltip,
  required final double size,
  required final VoidCallback? onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paper.withAlpha(0x24),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        constraints: BoxConstraints.tightFor(width: size, height: size),
        icon: Icon(icon, size: AppSpacing.xxl, color: AppColors.paper),
        onPressed: onPressed,
      ),
    );
  }
}

/// The four rounded corner brackets of the framing guide.
class const _FramePainter() extends CustomPainter {
  static const _arm = 34.0;
  static const _radius = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.paper
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    const r = _radius;
    for (final (sx, sy) in const [
      (1.0, 1.0),
      (-1.0, 1.0),
      (1.0, -1.0),
      (-1.0, -1.0),
    ]) {
      final ox = sx > 0 ? 0.0 : w;
      final oy = sy > 0 ? 0.0 : h;
      canvas.drawPath(
        Path()
          ..moveTo(ox + sx * _arm, oy)
          ..lineTo(ox + sx * r, oy)
          ..quadraticBezierTo(ox, oy, ox, oy + sy * r)
          ..lineTo(ox, oy + sy * _arm),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) => false;
}

class const _ReviewView({
  required final XFile photo,
  required final TextEditingController description,
  required final VoidCallback onRetake,
  required final VoidCallback onPublish,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PostCubit, PostState>(
          builder: (context, state) {
            final busy =
                state.isBusy ||
                (state.status == PostStatus.locating && state.position == null);
            final error = state.error;
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      child: Image.file(File(photo.path), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PfTextField(
                    controller: description,
                    hintText: l10n.postDescriptionHint,
                    maxLength: NewPost.maxDescriptionLength,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _errorMessage(l10n, error),
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.danger),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  if (busy) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: PfButton(
                          label: l10n.postRetake,
                          variant: PfButtonVariant.outline,
                          onPressed: busy ? null : onRetake,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: PfButton(
                          label: l10n.postPublish,
                          icon: Icons.send_rounded,
                          onPressed: busy ? null : onPublish,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static String _errorMessage(AppLocalizations l10n, PostError error) =>
      switch (error) {
        PostError.locationDenied => l10n.postErrorLocationDenied,
        PostError.locationUnavailable => l10n.postErrorLocation,
        PostError.network => l10n.postErrorNetwork,
        PostError.rateLimited => l10n.postErrorRateLimited,
        PostError.tooLarge => l10n.postErrorTooLarge,
        PostError.unknown => l10n.postErrorUnknown,
      };
}
