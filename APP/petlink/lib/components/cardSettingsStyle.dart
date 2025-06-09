import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:petlink/themes/customColors.dart';

class CardSettingsStyle extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSwitch;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;

  const CardSettingsStyle(
    this.icon, 
    this.title, 
    this.subtitle, {
    this.isSwitch = false,
    this.onSwitchChanged,
    this.onTap,
    super.key
    });

  @override
  State<CardSettingsStyle> createState() => _CardsettingsStyleState();
}


class _CardsettingsStyleState extends State<CardSettingsStyle> {
  late var custom = Theme.of(context).extension<CustomColors>()!;
  late var tema = Theme.of(context).colorScheme;
  bool switchValue = false;

  @override
  Widget build(BuildContext context) {
    custom = Theme.of(context).extension<CustomColors>()!;
    return GestureDetector(
      onTap: widget.onTap, // Detectar el clic y ejecutar el callback
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: custom.contenedor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              shadows: [
                BoxShadow(
                  color: custom.sombraContenedor,
                  blurRadius: 5,
                  offset: Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: ShapeDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: custom.colorEspecial.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: 35,
                      color: custom.colorEspecial,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.43,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                if (widget.isSwitch)
                  Switch(
                    value: switchValue,
                    onChanged: (value) {
                      setState(() {
                        switchValue = value;
                      });
                      if (widget.onSwitchChanged != null) {
                        widget.onSwitchChanged!(value);
                      }
                    },
                    activeColor: custom.colorEspecial,
                    inactiveThumbColor: custom.contenedor.withValues(alpha: 0.5),
                    inactiveTrackColor: custom.colorEspecial.withValues(alpha: 0.3),
                  )
                else
                  Icon(LineAwesomeIcons.arrow_right, color: custom.colorEspecial),
                SizedBox(width: 7),
              ],
            ),
          ),
        ],
      ),
    );
  }
}