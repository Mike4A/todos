import 'package:flutter/material.dart';
import 'package:todos/models/todo.dart';
import 'package:todos/widgets/todo_widget.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key, required this.title});

  final String title;

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Todo> _todos = [];
  final TextEditingController _addTodoController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _populateList();
  }

  Future<void> _populateList() async {
    final loadedTodos = await _loadTodos();
    setState(() {
      _todos.clear();
      _todos.addAll(loadedTodos);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _todos.length; i++) {
        _listKey.currentState?.insertItem(i);
      }
    });
  }

  Future<List<Todo>> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('todos');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Todo.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = _todos.map((todo) => todo.toJson()).toList();
    final String jsonString = jsonEncode(jsonList);
    await prefs.setString('todos', jsonString);
  }

  void _handleDeleteTap(Todo todo) {
    final index = _todos.indexOf(todo);
    _todos.remove(todo);
    _removeTodoWidget(index, todo);
    _saveTodos();
  }

  void _removeTodoWidget(int index, Todo todo) {
    _listKey.currentState!.removeItem(
      index,
      (context, animation) => SizeTransition(sizeFactor: animation, child: _buildTodoDummy(todo)),
      duration: const Duration(milliseconds: 500),
    );
  }

  void _handleDoneChanged(Todo todo, bool done) {
    setState(() => todo.done = done);
    _saveTodos();
  }

  void _handleItemDrop(Todo incoming, int targetIndex) {
    final oldIndex = _todos.indexOf(incoming);
    if (oldIndex == targetIndex) return;
    _todos.removeAt(oldIndex);
    _todos.insert(targetIndex, incoming);
    _removeTodoWidget(oldIndex, incoming);
    _listKey.currentState!.insertItem(targetIndex, duration: const Duration(milliseconds: 500));
    _saveTodos();
  }

  void _handleAddTodo() {
    FocusScope.of(context).unfocus();
    if (_addTodoController.text.isEmpty) return;
    final newIndex = _todos.length;
    _todos.add(Todo(title: _addTodoController.text));
    _addTodoController.clear();
    _listKey.currentState!.insertItem(newIndex, duration: const Duration(milliseconds: 500));
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    }
    _saveTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Column(children: [_buildTodoList(context), _buildAddTodo(context)]),
    );
  }

  TodoWidget _buildTodoDummy(Todo todo) {
    return TodoWidget(todo: todo, onDoneChanged: (_, _) {}, onDeleteTap: (_) {});
  }

  Widget _buildTodoList(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.inversePrimary,
              HSLColor.fromAHSL(0.5, 200, 1, 0.6).toColor(),
              Colors.black,
              Colors.black,
              HSLColor.fromAHSL(0.5, 170, 1, 0.6).toColor(),
              Theme.of(context).colorScheme.inversePrimary,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.025, 0.1, 0.9, 0.975, 1],
          ),
        ),
        child: AnimatedList(
          controller: _scrollController,
          key: _listKey,
          initialItemCount: _todos.length,
          itemBuilder: (context, index, animation) {
            final todo = _todos[index];
            return DragTarget<Todo>(
              onWillAcceptWithDetails: (details) {
                return details.data != todo;
              },
              onAcceptWithDetails: (details) {
                _handleItemDrop(details.data, index);
              },
              builder: (context, candidateData, rejectedData) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: TodoWidget(
                    key: ValueKey(todo),
                    todo: todo,
                    onDoneChanged: _handleDoneChanged,
                    onDeleteTap: _handleDeleteTap,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddTodo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      color: Theme.of(context).colorScheme.inversePrimary,
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _addTodoController,
                decoration: InputDecoration(
                  hintText: 'Neues Todo eingeben',
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          RawMaterialButton(
            onPressed: _handleAddTodo,
            shape: CircleBorder(),
            fillColor: Colors.white,
            constraints: BoxConstraints.tightFor(width: 40, height: 40),
            child: Icon(Icons.add_rounded, color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }
}
