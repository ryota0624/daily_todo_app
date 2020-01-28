import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/usecase/create_todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:flutter/material.dart';

class TodoCreationConfirmed extends UiEvent {
  TodoCreationConfirmed(this.subject);

  final String subject;
}

// Create a Form widget.
class TodoCreateForm extends StatefulWidget {
  const TodoCreateForm({
    @required this.inputPort,
    @required this.listID,
  });

  final InputPort<CreateTodoParam> inputPort;
  final ID<DailyTodoList> listID;

  @override
  TodoCreateFormState createState() => TodoCreateFormState();
}

class TodoCreateFormState extends State<TodoCreateForm> {
  String _inputText = '';

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<TodoCreateFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Row(
        children: <Widget>[
          Flexible(child: TextFormField(
            onChanged: (text) {
              _inputText = text;
            },
          )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: RaisedButton(
              onPressed: () {
                if (_inputText.isEmpty) {
                  return;
                }
                TodoCreationConfirmed(_inputText);
                widget.inputPort.put(
                  CreateTodoParam(
                    listID: widget.listID,
                    subject: _inputText,
                    labels: [],
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
