import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Six digit boxes fed by one invisible text field, so that paste and the
/// platform "code from SMS / email" autofill work.
class PfOtpField extends StatefulWidget {
  const PfOtpField({
    super.key,
    required this.onChanged,
    this.length = 6,
    this.autofocus = true,
  });

  final ValueChanged<String> onChanged;
  final int length;
  final bool autofocus;

  @override
  State<PfOtpField> createState() => _PfOtpFieldState();
}

class _PfOtpFieldState extends State<PfOtpField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;
    return GestureDetector(
      onTap: _focus.requestFocus,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < widget.length; i++)
                _Box(
                  digit: i < code.length ? code[i] : '',
                  active:
                      _focus.hasFocus &&
                      i == code.length.clamp(0, widget.length - 1),
                ),
            ],
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                autofocus: widget.autofocus,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                enableInteractiveSelection: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class const _Box({required final String digit, required final bool active})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 53,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? AppColors.night : AppColors.trait,
          width: 2,
        ),
      ),
      child: Text(digit, style: Theme.of(context).textTheme.displaySmall),
    );
  }
}
