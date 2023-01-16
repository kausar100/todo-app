import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_list/models/task.dart';

class TodoListScreen extends StatelessWidget {
  TodoListScreen({super.key});

  final String _firestoreCollection = 'todos';

  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    FirebaseFirestore.instance
        .collection(_firestoreCollection)
        .add({'title': _controller.text});
    _controller.text = '';
  }

  Widget _buildList(QuerySnapshot snapshot) {
    return ListView.builder(
      itemCount: snapshot.docs.length,
      itemBuilder: (context, index) {
        final doc = snapshot.docs[index];
        final task = Task.fromSnapshot(doc);

        return _buildListItem(task);
      },
    );
  }

  Widget _buildBody(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _controller,
                  decoration:
                      const InputDecoration(hintText: 'Enter task name'),
                )),
                ElevatedButton(
                    onPressed: () {
                      _addTask();
                    },
                    child: const Text(
                      'Add Task',
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(_firestoreCollection)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }
                return Expanded(child: _buildList(snapshot.data!));
              },
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildListItem(Task task) {
    return Dismissible(
      key: Key(task.taskId!),
      onDismissed: (direction) {
        _deleteTask(task);
      },
      background: Container(color: Colors.red),
      child: ListTile(
        title: Text(task.title),
      ),
    );
  }

  void _deleteTask(Task task) async {
    await FirebaseFirestore.instance
        .collection(_firestoreCollection)
        .doc(task.taskId!)
        .delete();
  }
}
