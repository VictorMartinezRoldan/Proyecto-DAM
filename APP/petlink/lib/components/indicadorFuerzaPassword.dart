import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IndicadorFuerzaPassword extends StatelessWidget {
  final String password;
  final Color? weakColor;
  final Color? mediumColor;
  final Color? strongColor;
  final Color? textColor;
  final double? height;

  const IndicadorFuerzaPassword({
    super.key,
    required this.password,
    this.weakColor = Colors.red,
    this.mediumColor = Colors.orange,
    this.strongColor = Colors.green,
    this.textColor,
    this.height = 6,
  });

  String _evaluarFuerza(String password) {
    if (password.isEmpty) return '';
    if (password.length < 6) return 'weak';
    
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSymbol = password.contains(RegExp(r'[!@#$%^&*]'));
    
    final categoriesMet = [hasUpperCase, hasLowerCase, hasNumber, hasSymbol]
        .where((met) => met)
        .length;

    if (password.length >= 8 && categoriesMet >= 3) {
      return 'strong';
    } else if (password.length >= 6 && categoriesMet >= 2) {
      return 'medium';
    }
    return 'weak';
  }

  @override
  Widget build(BuildContext context) {
    final strength = _evaluarFuerza(password);
    final theme = Theme.of(context);
    final defaultTextColor = textColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.6);

    if (password.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.editPasswordStrengthIndicatorLabel,
          style: TextStyle(
            fontSize: 12,
            color: defaultTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength == 'weak' ? 0.33 : strength == 'medium' ? 0.66 : 1.0,
                backgroundColor: Colors.grey[300],
                color: strength == 'weak' 
                    ? weakColor 
                    : strength == 'medium' 
                        ? mediumColor 
                        : strongColor,
                minHeight: height,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              strength == 'weak' 
                  ? AppLocalizations.of(context)!.editPasswordStrengthIndicatorLabelWeak 
                  : strength == 'medium' 
                      ? AppLocalizations.of(context)!.editPasswordStrengthIndicatorLabelMedium 
                      : AppLocalizations.of(context)!.editPasswordStrengthIndicatorLabelStrong,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: strength == 'weak' 
                    ? weakColor 
                    : strength == 'medium' 
                        ? mediumColor 
                        : strongColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}