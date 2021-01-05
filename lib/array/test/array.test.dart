import 'package:test/test.dart';
import "../array.dart" as array;

void main() {
  final dollar = (String arr) => arr.split(" ");

  group("tonal-array", () {
    test("range", () {
      expect(array.range(-2, 2), equals([-2, -1, 0, 1, 2]));
      expect(array.range(2, -2), equals([2, 1, 0, -1, -2]));
      expect(array.range(1), equals([]));
      expect(array.range(), equals([]));
    });

    test("rotate", () {
      expect(array.rotate(2, dollar("a b c d e")), equals(dollar("c d e a b")));
    });

    test("compact", () {
      final input = ["a", 1, 0, true, false, null, null];
      final result = ["a", 1, 0, true];
      expect(array.compact(input), equals(result));
    });

    test("sort", () {
      expect(array.sort(dollar("c f g a b h j")), equals(dollar("C F G A B")));
      expect(array.sort(dollar("c f g a b h j j h b a g f c")),
          equals(dollar("C C F F G G A A B B")));
      expect(array.sort(dollar("c2 c5 c1 c0 c6 c")),
          equals(dollar("C C0 C1 C2 C5 C6")));
    });

    test("unique", () {
      expect(array.unique(dollar("a b c2 1p p2 c2 b c c3")),
          equals(dollar("C A B C2 C3")));
    });

    test("shuffle", () {
      final rnd = () => 0.2;
      expect(
          array.shuffle(dollar("a b c d"), rnd), equals(["b", "c", "d", "a"]));
    });

    test("permutations", () {
      expect(
          array.permutations(["a", "b", "c"]),
          equals([
            ["a", "b", "c"],
            ["b", "a", "c"],
            ["b", "c", "a"],
            ["a", "c", "b"],
            ["c", "a", "b"],
            ["c", "b", "a"]
          ]));
    });
  });
}
