import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todos/models/hue_provider.dart';
import 'package:todos/models/todo.dart';
import 'package:todos/widgets/hue_header.dart';
import 'package:todos/widgets/todo_widget.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todos/widgets/input_footer.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key, required this.title});

  final String title;

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final List<Todo> _todos = [];
  bool _isLoading = true;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  bool _isInputOpen = false;
  Todo? _editingTodo;
  final TextEditingController _inputController = TextEditingController();

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
      _isLoading = false;
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
      (context, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          child: ScaleTransition(scale: animation, child: _buildTodoDummy(todo)),
        ),
      ),
      duration: const Duration(milliseconds: 500),
    );
  }

  void _handleDoneChanged(Todo todo, bool done) {
    setState(() => todo.done = done);
    _saveTodos();
  }

  Future<void> _handleItemDrop(Todo incoming, int targetIndex) async {
    final oldIndex = _todos.indexOf(incoming);
    if (oldIndex == targetIndex) return;
    _todos.removeAt(oldIndex);
    _removeTodoWidget(oldIndex, incoming);
    await Future.delayed(Duration(milliseconds: 500));
    _todos.insert(targetIndex, incoming);
    _listKey.currentState!.insertItem(targetIndex, duration: const Duration(milliseconds: 500));
    _saveTodos();
  }

  void _openInput({Todo? editing}) {
    setState(() {
      _editingTodo = editing;
      _isInputOpen = true;
      _inputController.text = editing?.title ?? '';
    });
  }

  void _closeInput() {
    setState(() {
      _isInputOpen = false;
      _editingTodo = null;
      _inputController.clear();
    });
  }

  void _submitInput() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    if (_editingTodo != null) {
      final index = _todos.indexOf(_editingTodo!);
      setState(() => _todos[index].title = text);
    } else {
      final newIndex = _todos.length;
      final item = Todo(title: text);
      setState(() => _todos.add(item));
      _listKey.currentState?.insertItem(newIndex, duration: const Duration(milliseconds: 500));
    }
    _saveTodos();
    _closeInput();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hueA = context.watch<HueProvider>().hueA;
    return Scaffold(
      body: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: MediaQuery.of(context).padding.top,
            color: HSLColor.fromAHSL(0.75, hueA, 1, 0.6).toColor(),
          ),
          HueHeader(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildTodoList(context),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  TodoWidget _buildTodoDummy(Todo todo) {
    return TodoWidget(todo: todo, onDoneChanged: (_, _) {}, onDeleteTap: (_) {}, onTap: (_) {});
  }

  Widget _buildTodoList(BuildContext context) {
    final hueA = context.watch<HueProvider>().hueA;
    final hueB = context.watch<HueProvider>().hueB;
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * 0.01,
            vertical: constraints.maxHeight * 0.05,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                HSLColor.fromAHSL(0.75, hueA, 1, 0.6).toColor(),
                HSLColor.fromAHSL(0.5, hueA, 1, 0.6).toColor(),
                Colors.black,
                Colors.black,
                HSLColor.fromAHSL(0.5, hueB, 1, 0.6).toColor(),
                HSLColor.fromAHSL(0.75, hueB, 1, 0.6).toColor(),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.025, 0.1, 0.9, 0.975, 1],
            ),
          ),
          child: AnimatedList(
            controller: _scrollController,
            key: _listKey,
            initialItemCount: 0,
            itemBuilder: (context, index, animation) {
              //if (index < 0 || index > _todos.length - 1) return SizedBox.shrink();
              final todo = _todos[index];
              return DragTarget<Todo>(
                onWillAcceptWithDetails: (details) {
                  return details.data != todo;
                },
                onAcceptWithDetails: (details) {
                  _handleItemDrop(details.data, index);
                },
                builder: (context, candidateData, rejectedData) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      child: ScaleTransition(
                        scale: animation, // 0.0 bis 1.0
                        alignment: Alignment.center,
                        child: TodoWidget(
                          key: ValueKey(todo),
                          todo: todo,
                          onDoneChanged: _handleDoneChanged,
                          onDeleteTap: _handleDeleteTap,
                          onTap: (todo) => _openInput(editing: todo),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return InputFooter(
      isInputOpen: _isInputOpen,
      controller: _inputController,
      onOpen: () => _openInput(),
      onClose: _closeInput,
      onSubmit: (_) => _submitInput(),
    );
  }
}
