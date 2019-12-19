import 'package:daily_todo_app/todo/label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toString()は引数にとった文字列で返す', () async {
    var labelString = "shopping";
    expect(Label(labelString).toString(), equals(labelString));
  });
}
