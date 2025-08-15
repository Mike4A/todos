import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todos/models/hue_provider.dart';
import '../models/todo.dart';

class TodoWidget extends StatelessWidget {
  final Todo todo;
  final void Function(Todo, bool) onDoneChanged;
  final void Function(Todo) onDeleteTap;
  final void Function(Todo) onTap;

  const TodoWidget({
    super.key,
    required this.todo,
    required this.onDoneChanged,
    required this.onDeleteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Todo>(
      data: todo,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.97,
          child: Opacity(opacity: 0.7, child: _buildTodoContent(context)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildTodoContent(context)),
      child: GestureDetector(onTap: () => onTap(todo), child: _buildTodoContent(context)),
    );
  }

  Widget _buildTodoContent(BuildContext context) {
    final hueA = context.watch<HueProvider>().hueA;
    final hueB = context.watch<HueProvider>().hueB;
    final hueCore = context.watch<HueProvider>().hueCore;
    return Container(
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HSLColor.fromAHSL(1, hueCore, 0.5, 0.5).toColor()),
        gradient: LinearGradient(
          colors: [
            HSLColor.fromAHSL(0.5, hueA, 1, 0.4).toColor(),
            Colors.transparent,
            HSLColor.fromAHSL(0.5, hueB, 1, 0.4).toColor(),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: HSLColor.fromAHSL(0.25, hueCore, 0.5, 0.5).toColor(),
            spreadRadius: 3,
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            checkColor: HSLColor.fromAHSL(1, hueCore, 1, 0.9).toColor(),
            value: todo.done,
            onChanged: (v) => onDoneChanged(todo, v!),
            side: BorderSide(color: HSLColor.fromAHSL(1, hueCore, 0.5, 0.5).toColor(), width: 2),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return HSLColor.fromAHSL(1, hueCore, 0.5, 0.5).toColor();
              }
              return Colors.white;
            }),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 3, 6, 3),
              child: Text(
                todo.title,
                style: TextStyle(
                  fontSize: 16,
                  color: todo.done
                      ? HSLColor.fromAHSL(1, hueCore, 0.5, 0.5).toColor()
                      : HSLColor.fromAHSL(1, hueCore, 1, 0.9).toColor(),
                  decoration: todo.done ? TextDecoration.lineThrough : TextDecoration.none,
                  decorationColor: HSLColor.fromAHSL(1, hueCore, 0.5, 0.5).toColor(),
                ),
              ),
            ),
          ),
          if (todo.done)
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () => onDeleteTap(todo),
              color: HSLColor.fromAHSL(1, hueCore, 1, 0.9).toColor(),
              tooltip: 'Löschen',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
