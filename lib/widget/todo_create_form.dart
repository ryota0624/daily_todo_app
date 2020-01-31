import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/usecase/create_todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

mixin Notifier {
  void notifyListeners();
}

abstract class TodoCreationModel implements ChangeNotifier {
  TodoCreationModel(this.inputPort);

  final InputPort<CreateTodoParam> inputPort;

  String _text;
  final Set<String> _labels = {};

  void inputText(String text) {
    _text = text;
    notifyListeners();
  }

  void addLabel(String label) {
    _labels.add(label);
    notifyListeners();
  }

  void submitCreation(ID<DailyTodoList> listID) {
    if (getText().isEmpty) {
      return;
    }
    inputPort.put(
      CreateTodoParam(
        listID: listID,
        subject: getText(),
        labels: getLabels().toList(),
      ),
    );
  }

  String getText() => _text;

  Set<String> getLabels() => Set.from(_labels);
}

class TodoCreationModelFWidget extends TodoCreationModel with ChangeNotifier {
  TodoCreationModelFWidget(InputPort<CreateTodoParam> inputPort)
      : super(inputPort);
}

class TodoCreationConfirmed extends UiEvent {
  TodoCreationConfirmed(this.subject);

  final String subject;
}

// Create a Form widget.
class TodoCreateForm extends StatefulWidget {
  const TodoCreateForm({
    @required this.listID,
  });

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
    return Consumer<TodoCreationModel>(
        builder: (_, model, __) => Form(
              key: _formKey,
              child: Row(
                children: <Widget>[
                  Flexible(
                      child: TextFormField(
                    onChanged: model.inputText,
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: RaisedButton(
                      onPressed: () => model.submitCreation(widget.listID),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            )); // Build a Form widget using the _formKey created above.)
  }
}
