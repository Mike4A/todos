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
      child: Column(
        children: [
          AnimatedSwitcher(
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
        ],
      ),
    );
  }

  Widget _buildPaletteButton() {
    return Center(
      key: const ValueKey('paletteButton'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Todos', style: TextStyle(fontSize: 20, color: Colors.white)),
          IconButton(
            icon: const Icon(Icons.palette, color: Colors.white),
            onPressed: () {
              setState(() => _isHuePickerOpen = true);
            },
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildHueSliders(BuildContext context, HueProvider hueProvider) {
    return Column(
      key: const ValueKey('hueSliders'),
      children: [
        _gradientSlider(value: hueProvider.hueA, onChanged: (v) => hueProvider.setHueA(v)),
        const SizedBox(height: 8),
        _gradientSlider(value: hueProvider.hueB, onChanged: (v) => hueProvider.setHueB(v)),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() => _isHuePickerOpen = false);
            hueProvider.save();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
          child: const Text('Speichern'),
        ),
      ],
    );
  }

  Widget _gradientSlider({required double value, required ValueChanged<double> onChanged}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 16,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                for (int i = 0; i <= 360; i += 30)
                  HSLColor.fromAHSL(1, i.toDouble(), 1, 0.5).toColor(),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: HSLColor.fromAHSL(1, value, 1, 0.75).toColor()),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackShape: null,
            thumbColor: Colors.white,
            overlayShape: SliderComponentShape.noOverlay,
            trackHeight: 0,
          ),
          child: Slider(min: 0, max: 359.9, value: value, onChanged: (v) => onChanged(v)),
        ),
      ],
    );
  }
}
