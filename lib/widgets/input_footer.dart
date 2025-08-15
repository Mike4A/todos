import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hue_provider.dart';

class InputFooter extends StatelessWidget {
  final bool isInputOpen;
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final ValueChanged<String> onSubmit;
  final TextEditingController controller;

  const InputFooter({
    super.key,
    required this.isInputOpen,
    required this.onOpen,
    required this.onClose,
    required this.onSubmit,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final hueB = context.watch<HueProvider>().hueB;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8),
      color: HSLColor.fromAHSL(0.75, hueB, 1, 0.6).toColor(),
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
        child: isInputOpen ? _buildInputArea(context) : _buildAddButton(context),
      ),
    );
  }

  Column _buildInputArea(BuildContext context) {
    return Column(
      key: const ValueKey('input'),
      children: [
        TextField(
          enableInteractiveSelection: false,
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'Titel',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onClose,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Abbrechen'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => onSubmit(controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
              ),
              child: const Text('Speichern'),
            ),
          ],
        ),
      ],
    );
  }

  Center _buildAddButton(BuildContext context) {
    return Center(
      key: const ValueKey('addButton'),
      child: ElevatedButton(
        onPressed: onOpen,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        child: const Text('+ Neues Todo'),
      ),
    );
  }
}
