import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todos/models/hue_provider.dart';

class HueHeader extends StatefulWidget {
  const HueHeader({super.key});

  @override
  State<HueHeader> createState() => _HueHeaderState();
}

class _HueHeaderState extends State<HueHeader> {
  bool _isHuePickerOpen = false;

  @override
  Widget build(BuildContext context) {
    final hueProvider = context.watch<HueProvider>();
    final hueA = hueProvider.hueA;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8),
      color: HSLColor.fromAHSL(0.75, hueA, 1, 0.6).toColor(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInBack,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: _isHuePickerOpen
            ? _buildHueSliders(context, hueProvider)
            : _buildPaletteButton(),
      ),
    );
  }

  Widget _buildPaletteButton() {
    return Center(
      key: const ValueKey('paletteButton'),
      child: IconButton(
        icon: const Icon(Icons.palette, color: Colors.white),
        onPressed: () {
          setState(() => _isHuePickerOpen = true);
        },
      ),
    );
  }

  Widget _buildHueSliders(BuildContext context, HueProvider hueProvider) {
    return Column(
      key: const ValueKey('hueSliders'),
      children: [
        _gradientSlider(
          value: hueProvider.hueA,
          onChanged: (v) => hueProvider.setHueA(v),
        ),
        const SizedBox(height: 8),
        _gradientSlider(
          value: hueProvider.hueB,
          onChanged: (v) => hueProvider.setHueB(v),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _isHuePickerOpen = false),
          child: const Text('Schließen', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _gradientSlider({
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 16,
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: Slider(
        min: 0,
        max: 360,
        divisions: 360,
        value: value,
        onChanged: onChanged,
        activeColor: Colors.transparent,
        inactiveColor: Colors.transparent,
        thumbColor: Colors.white,
      ),
    );
  }
}
