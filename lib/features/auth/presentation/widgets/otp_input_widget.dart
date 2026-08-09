import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_radius.dart';

class OtpInputWidget extends StatefulWidget {
  const OtpInputWidget({
    super.key,
    this.onChanged,
    this.onCompleted,
  });

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  static const _otpLength = 6;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onValueChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits != value) {
      _controller.value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }

    widget.onChanged?.call(digits);

    if (digits.length == _otpLength) {
      widget.onCompleted?.call(digits);
      _focusNode.unfocus();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;

    return Column(
      children: [
        GestureDetector(
          onTap: _focusNode.requestFocus,
          child: Row(
            children: List.generate(_otpLength, (index) {
              final digit = index < code.length ? code[index] : '';

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < _otpLength - 1 ? 8 : 0,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: _focusNode.hasFocus && index == code.length
                            ? AppColors.primary
                            : AppColors.divider,
                        width:
                            _focusNode.hasFocus && index == code.length ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      digit,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Opacity(
          opacity: 0,
          child: SizedBox(
            height: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: _otpLength,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _onValueChanged,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
