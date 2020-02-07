import 'package:daily_todo_app/todo/label.dart';
import 'package:test/test.dart';

void main() {
  group('toString()', () {
    test('引数にとった文字列で返す', () async {
      const labelString = 'shopping';
      expect(Label(labelString).toString(), equals(labelString));
    });
  });
}
