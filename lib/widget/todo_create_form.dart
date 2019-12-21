import 'package:daily_todo_app/adapter/todo_collection.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/usecase/create_todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:flutter/material.dart';

// Create a Form widget.
class TodoCreateForm extends StatefulWidget {
  @override
  TodoCreateFormState createState() {
    return TodoCreateFormState(
      null, // TODO inputportの実装
      CreateTodo(
          todoFactory: TodoFactory(
            TimeGetterDartCoreImpl(),
            TodoLabelsFactoryImpl(),
          ),
          todoCollection: TodoCollectionOnMap(),
          outputPort: null // TODO outputportの実装
      ),
    );
  }
}

class TodoCreateFormState extends State<TodoCreateForm> {
  final InputPort<CreateTodoParam> _inputPort;
  final CreateTodo _usecase;

  String _inputText = "";

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<TodoCreateFormState>.
  final _formKey = GlobalKey<FormState>();

  TodoCreateFormState(this._inputPort, this._usecase);

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            onChanged: (text) {
              _inputText = text;
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter subject';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                _usecase.execute(_inputPort);
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
