import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/shared/widgets/flex_with_highlighted_child.dart';


class IndoorLevelBar<T> extends StatefulWidget {
  final Map<T, String> levels;

  final T? active;

  final void Function(T key)? onSelect;

  const IndoorLevelBar({
    this.levels = const {},
    this.active,
    this.onSelect,
    super.key,
  });

  @override
  State<IndoorLevelBar<T>> createState() => _IndoorLevelBarState<T>();
}

class _IndoorLevelBarState<T> extends State<IndoorLevelBar<T>> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Semantics(
      container: true,
      label: localizations.levelBarSemantic,
      child: UnconstrainedBox(
        // size based on largest flex child
        child: IntrinsicWidth(
          child: Material(
            elevation: Theme.of(context).floatingActionButtonTheme.elevation ?? 8.0,
            shape: Theme.of(context).floatingActionButtonTheme.shape ?? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlexWithHighlightedChild(
              duration: const Duration(milliseconds: 600),
              curve: Curves.ease,
              vsync: this,
              active: widget.active != null
                ? widget.levels.keys.toList().reversed.toList().indexOf(widget.active!)
                : -1,
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.levels.entries.map((entry) => Semantics(
                selected: entry.key == widget.active,
                container: true,
                child: InkWell(
                  onTap: () => widget.onSelect?.call(entry.key),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    child: AnimatedDefaultTextStyle(
                      textAlign: TextAlign.center,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubicEmphasized,
                      style: entry.key == widget.active
                        ? TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        )
                        : TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      child: Text(entry.value),
                    ),
                  ),
                ),
              )).toList().reversed.toList(),
            ),
          ),
        ),
      ),
    );
  }
}
