import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.orangeAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('To-Do App'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {

              },
            ),
          ],
        ),
        body: const TodoList(),
      ),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<TodoItem> todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() async {
    List<Map<String, dynamic>> todoMaps = await dbHelper.getTodos();

    setState(() {
      todos = todoMaps
          .map((todo) => TodoItem(
        todo['task'],
        isCompleted: todo['is_completed'] == 1,
        id: todo['id'],
      ))
          .toList();
    });
  }

  void addTodo(String todo) async {
    TodoItem newTodo = TodoItem(todo);
    await dbHelper.insertTodo(newTodo.toMap());

    _loadTodos();
  }

  void removeTodo(int index) async {
    await dbHelper.deleteTodo(todos[index].id!);

    setState(() {
      todos.removeAt(index);
    });
  }

  void toggleCompleted(int index) async {
    todos[index].isCompleted = !todos[index].isCompleted;
    await dbHelper.updateTodo(todos[index].toMap());

    setState(() {});
  }

  void clearCompleted() async {
    List<int> completedIds = todos
        .where((todo) => todo.isCompleted)
        .map((todo) => todo.id!)
        .toList();
    for (int id in completedIds) {
      await dbHelper.deleteTodo(id);
    }

    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Theme.of(context).colorScheme.secondary,
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onSubmitted: (String todo) {
              addTodo(todo);
            },
            decoration: InputDecoration(
              hintText: 'Enter a task',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true,
              contentPadding: const EdgeInsets.all(16.0),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: todos.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: Checkbox(
                  value: todos[index].isCompleted,
                  onChanged: (bool? value) {
                    if (value != null) {
                      toggleCompleted(index);
                    }
                  },
                ),
                title: Text(
                  todos[index].task,
                  style: TextStyle(
                    decoration: todos[index].isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    removeTodo(index);
                  },
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: clearCompleted,
          child: const Text('Clear Completed'),
        ),
      ],
    );
  }
}

class TodoItem {
  String task;
  bool isCompleted;
  int? id;

  TodoItem(this.task, {this.isCompleted = false, this.id});

  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'is_completed': isCompleted ? 1 : 0,
    };
  }
}
