class Todo {
  String title;
  bool done;

  Todo({required this.title, this.done = false});

  Map<String, dynamic> toJson() => {'title': title, 'done': done};

  factory Todo.fromJson(Map<String, dynamic> json) =>
      Todo(title: json['title'], done: json['done']);
}
