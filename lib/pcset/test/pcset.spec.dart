import 'package:node_shims/node_shims.dart' as shims;
import 'package:test/test.dart';
import '../pcset.dart' as pcset;

class isTruthy extends Matcher {
  const isTruthy();

  @override
  bool matches(item, Map matchState) => shims.truthy(item);

  @override
  Description describe(Description description) => description.add('truthy');
}

void main() {
  final dollar = (String str) => str.split(" ").toList();

  group("pcset", () {
    test("chroma", () {
      expect(pcset.chroma(dollar("c d e")), equals("101010000000"));
      expect(pcset.chroma(dollar("g g#4 a bb5")), equals("000000011110"));
      expect(pcset.chroma(dollar("P1 M2 M3 P4 P5 M6 M7")),
          equals(pcset.chroma(dollar("c d e f g a b"))));
      expect(pcset.chroma("101010101010"), equals("101010101010"));
    });

    test("chromas", () {
      expect(pcset.chromas().length, equals(2048));
      expect(pcset.chromas()[0], equals("100000000000"));
      expect(pcset.chromas()[2047], equals("111111111111"));
      expect(pcset.chromas(0), equals([]));
      expect(pcset.chromas(1), equals(["100000000000"]));
      expect(pcset.chromas(12), equals(["111111111111"]));
      expect(pcset.chromas(2).length, equals(11));
    });

    test("intervals", () {
      expect(
          pcset.intervals("101010101010"), equals(dollar("1P 2M 3M 5d 6m 7m")));
      expect(pcset.intervals("1010"), equals([]));
    });

    test("isChroma", () {
      expect(pcset.isChroma("101010101010"), equals(true));
      expect(pcset.isChroma("1010101"), equals(false));
      expect(pcset.isChroma("blah"), equals(false));
      expect(pcset.isChroma("c d e"), equals(false));
    });

    test("isSubsetOf", () {
      final isInCMajor = pcset.isSubsetOf(dollar("c4 e6 g"));
      expect(isInCMajor(dollar("c2 g7")), equals(true));
      expect(isInCMajor(dollar("c2 e")), equals(true));
      expect(isInCMajor(dollar("c2 e3 g4")), equals(false));
      expect(isInCMajor(dollar("c2 e3 b5")), equals(false));
      expect(pcset.isSubsetOf(dollar("c d e"), dollar("c d")), equals(true));
    });

    test("isSubsetOf with chroma", () {
      final isSubset = pcset.isSubsetOf("101010101010");
      expect(isSubset("101000000000"), equals(true));
      expect(isSubset("111000000000"), equals(false));
    });

    test("isSupersetOf", () {
      final extendsCMajor = pcset.isSupersetOf(["c", "e", "g"]);
      expect(extendsCMajor(dollar("c2 g3 e4 f5")), equals(true));
      expect(extendsCMajor(dollar("e c g")), equals(false));
      expect(extendsCMajor(dollar("c e f")), equals(false));
      expect(pcset.isSupersetOf(["c", "d"], ["c", "d", "e"]), equals(true));
    });

    test("isSupersetOf with chroma", () {
      final isSuperset = pcset.isSupersetOf("101000000000");
      expect(isSuperset("101010101010"), equals(true));
      expect(isSuperset("110010101010"), equals(false));
    });

    test("isEqual", () {
      expect(pcset.isEqual(dollar("c2 d3 e7 f5"), dollar("c4 c d5 e6 f1")),
          isTruthy());
      expect(pcset.isEqual(dollar("c f"), dollar("c4 c f1")), isTruthy());
    });

    test("includes", () {
      expect(pcset.includes(dollar("c d e"), "C4"), equals(true));
      expect(pcset.includes(dollar("c d e"), "C#4"), equals(false));
    });

    test("filter", () {
      expect(pcset.filter(dollar("c d e"), dollar("c2 c#2 d2 c3 c#3 d3")),
          equals(dollar("c2 d2 c3 d3")));
      expect(pcset.filter(dollar("c"), dollar("c2 c#2 d2 c3 c#3 d3")),
          equals(dollar("c2 c3")));
    });

    test("modes", () {
      expect(
          pcset.modes(dollar("c d e f g a b")),
          equals([
            "101011010101",
            "101101010110",
            "110101011010",
            "101010110101",
            "101011010110",
            "101101011010",
            "110101101010"
          ]));
      expect(
          pcset.modes(dollar("c d e f g a b"), false),
          equals([
            "101011010101",
            "010110101011",
            "101101010110",
            "011010101101",
            "110101011010",
            "101010110101",
            "010101101011",
            "101011010110",
            "010110101101",
            "101101011010",
            "011010110101",
            "110101101010"
          ]));
      expect(pcset.modes("blah bleh"), equals([]));
    });
  });
}
