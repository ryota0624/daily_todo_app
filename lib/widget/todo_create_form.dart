import 'package:daily_todo_app/usecase/create_todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:flutter/material.dart';

// Create a Form widget.
class TodoCreateForm extends StatefulWidget {
  final InputPort<CreateTodoParam> inputPort;

  TodoCreateForm(this.inputPort);

  @override
  TodoCreateFormState createState() => TodoCreateFormState(inputPort);
}

class TodoCreateFormState extends State<TodoCreateForm> {
  final InputPort<CreateTodoParam> _inputPort;

  String _inputText = "";

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<TodoCreateFormState>.
  final _formKey = GlobalKey<FormState>();

  TodoCreateFormState(this._inputPort);

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
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                _inputPort
                    .put(CreateTodoParam(subject: _inputText, labels: []));
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
