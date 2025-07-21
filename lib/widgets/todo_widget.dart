import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoWidget extends StatelessWidget {
  final Todo todo;
  final void Function(Todo, bool) onDoneChanged;
  final void Function(Todo) onDeleteTap;

  const TodoWidget({
    super.key,
    required this.todo,
    required this.onDoneChanged,
    required this.onDeleteTap,
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
      child: _buildTodoContent(context),
    );
  }

  Widget _buildTodoContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Colors.transparent,
            Colors.transparent,
            Theme.of(context).primaryColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5, 0.5, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withAlpha(64),
            spreadRadius: 3,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: todo.done,
            onChanged: (v) => onDoneChanged(todo, v!),
            side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2),
          ),
          Expanded(
            child: Text(
              todo.title,
              style: TextStyle(
                fontSize: 20,
                color: todo.done
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColorLight,
                decoration: todo.done ? TextDecoration.lineThrough : TextDecoration.none,
                decorationColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => onDeleteTap(todo),
            color: Theme.of(context).primaryColorLight,
            tooltip: 'Löschen',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
