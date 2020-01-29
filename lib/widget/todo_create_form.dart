import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/usecase/create_todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

mixin Notifier {
  void notifyListeners();
}

class MockChangeNotifier implements ChangeNotifier {
  @override
  void addListener(listener) {
    // TODO: implement addListener
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  // TODO: implement hasListeners
  bool get hasListeners => null;

  @override
  void notifyListeners() {
    // TODO: implement notifyListeners
  }

  @override
  void removeListener(listener) {
    // TODO: implement removeListener
  }
}

abstract class TodoCreationModel implements ChangeNotifier {
  String _text;

  void inputText(String text) {
    _text = text;
    notifyListeners();
  }

  String getText() => _text;
}

class TodoCreationModelFWidget extends TodoCreationModel with ChangeNotifier {
}

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

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<TodoCreateFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoCreationModelFWidget>(
        builder: (_, model, __) => Form(
              key: _formKey,
              child: Row(
                children: <Widget>[
                  Flexible(child: TextFormField(
                    onChanged: (text) {
                       model.inputText(text);
                    },
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: RaisedButton(
                      onPressed: () {
                        if (model.getText().isEmpty) {
                          return;
                        }
                        TodoCreationConfirmed(model.getText());
                        widget.inputPort.put(
                          CreateTodoParam(
                            listID: widget.listID,
                            subject: model.getText(),
                            labels: [],
                          ),
                        );
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            )); // Build a Form widget using the _formKey created above.)
  }
}
