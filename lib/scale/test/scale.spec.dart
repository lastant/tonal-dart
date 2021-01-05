import 'package:node_shims/node_shims.dart' as shims;
import 'package:test/test.dart';
import '../scale.dart' as scale;

class isTruthy extends Matcher {
  const isTruthy();

  @override
  bool matches(item, Map matchState) => shims.truthy(item);

  @override
  Description describe(Description description) => description.add('truthy');
}

void main() {
  final dollar = (String s) => s.split(" ");

  group("tonal-scale", () {
    test("props", () {
      expect(
          scale.props("major"),
          equals({
            'name': "major",
            'names': ["major", "ionian"],
            'intervals': ["1P", "2M", "3M", "4P", "5P", "6M", "7M"],
            'chroma': "101011010101",
            'setnum': 2773
          }));
    });
    test("tokenize", () {
      expect(scale.tokenize("c major"), equals(["C", "major"]));
      expect(scale.tokenize("cb3 major"), equals(["Cb3", "major"]));
      expect(scale.tokenize("melodic minor"), equals(["", "melodic minor"]));
      expect(scale.tokenize("c"), equals(["C", ""]));
      expect(scale.tokenize(), equals(["", ""]));
    });

    test("exists", () {
      expect(scale.exists("major"), equals(true));
      expect(scale.exists("Db major"), equals(true));
      expect(scale.exists("Maj7"), equals(false));
    });

    test("intervals", () {
      expect(scale.intervals("major"), equals(dollar("1P 2M 3M 4P 5P 6M 7M")));
      expect(
          scale.intervals("C major"), equals(dollar("1P 2M 3M 4P 5P 6M 7M")));
      expect(scale.intervals("blah"), equals([]));
    });

    test("notes", () {
      expect(scale.notes("C major"), equals(dollar("C D E F G A B")));
      expect(scale.notes("C", "major"), equals(dollar("C D E F G A B")));
      expect(
          scale.notes("C4", "major"), equals(dollar("C4 D4 E4 F4 G4 A4 B4")));
      expect(scale.notes("eb", "bebop"), equals(dollar("Eb F G Ab Bb C Db D")));
      expect(scale.notes("C", "no-scale"), equals([]));
      const penta = [null, null, null, null, null];
      expect(scale.notes("no-note", "pentatonic"), equals(penta));
    });

    test("names", () {
      expect(scale.names().length > 0, isTruthy());
      expect(scale.names(true).length > scale.names().length, isTruthy());
    });

    test("mode names", () {
      expect(
          scale.modeNames("pentatonic"),
          equals([
            ["1P", "major pentatonic"],
            ["2M", "egyptian"],
            ["3M", "malkos raga"],
            ["5P", "ritusen"],
            ["6M", "minor pentatonic"]
          ]));
      expect(
          scale.modeNames("whole tone pentatonic"),
          equals([
            ["1P", "whole tone pentatonic"]
          ]));
      expect(
          scale.modeNames("C pentatonic"),
          equals([
            ["C", "major pentatonic"],
            ["D", "egyptian"],
            ["E", "malkos raga"],
            ["G", "ritusen"],
            ["A", "minor pentatonic"]
          ]));
      expect(
          scale.modeNames("C whole tone pentatonic"),
          equals([
            ["C", "whole tone pentatonic"]
          ]));
    });

    test("chords: find all chords that fits into this scale", () {
      expect(
          scale.chords("pentatonic"), equals(dollar("5 64 M M6 Madd9 Msus2")));
      expect(scale.chords("none"), equals([]));
    });

    test("supersets: find all scales that extends this one", () {
      expect(
          scale.supersets("major"),
          equals([
            "bebop",
            "bebop dominant",
            "bebop major",
            "chromatic",
            "ichikosucho"
          ]));
      expect(scale.supersets("none"), equals([]));
    });

    test("subsets: all scales that are included in the given one", () {
      expect(scale.subsets("major"),
          equals(["ionian pentatonic", "major pentatonic", "ritusen"]));
      expect(scale.subsets("none"), equals([]));
    });

    test("toScale", () {
      expect(scale.toScale(dollar("C4 c3 C5 C4 c4")), equals(["C"]));
      expect(scale.toScale(dollar("C4 f3 c#10 b5 d4 cb4")),
          equals(dollar("C C# D F B Cb")));
      expect(scale.toScale(dollar("D4 c#5 A5 F#6")),
          equals(["D", "F#", "A", "C#"]));
    });
  });
}
