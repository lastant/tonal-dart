import 'package:test/test.dart';
import '../chord.dart' as chord;

void main() {
  group("tonal-chord", () {
    test("tokenize", () {
      expect(chord.tokenize("C"), equals(["C", ""]));
      expect(chord.tokenize("Cmaj7"), equals(["C", "maj7"]));
      expect(chord.tokenize("c7"), equals(["C", "7"]));
      expect(chord.tokenize("maj7"), equals(["", "maj7"]));
      expect(chord.tokenize("c#4 m7b5"), equals(["C#4", "m7b5"]));
      expect(chord.tokenize("c#4m7b5"), equals(["C#4", "m7b5"]));
      expect(chord.tokenize("Cb7b5"), equals(["Cb", "7b5"]));
      expect(chord.tokenize("Eb7add6"), equals(["Eb", "7add6"]));
      expect(chord.tokenize("Bb6b5"), equals(["Bb", "6b5"]));
      expect(chord.tokenize("aug"), equals(["", "aug"]));
      expect(chord.tokenize("C11"), equals(["C", "11"]));
      expect(chord.tokenize("C13no5"), equals(["C", "13no5"]));
    });

    test("notes", () {
      expect(chord.notes("Cmaj7"), equals(["C", "E", "G", "B"]));
      expect(chord.notes("Eb7add6"), equals(["Eb", "G", "Bb", "Db", "C"]));
      expect(chord.notes("C4 maj7"), equals(["C4", "E4", "G4", "B4"]));
      expect(chord.notes("C7"), equals(["C", "E", "G", "Bb"]));
      expect(chord.notes("C64"), equals(["G", "C", "E"]));
      expect(chord.notes("Cmaj7#5"), equals(["C", "E", "G#", "B"]));
      expect(chord.notes("blah"), equals([]));
    });

    test("notes with two params", () {
      expect(chord.notes("C", "maj7"), equals(["C", "E", "G", "B"]));
      // see: https://github.com/danigb/tonal/issues/82
      expect(chord.notes("C6", "maj7"), equals(["C6", "E6", "G6", "B6"]));
    });

    // see: https://github.com/danigb/tonal/issues/52
    test("augmented chords (issue #52)", () {
      expect(chord.notes("Caug"), equals(["C", "E", "G#"]));
      expect(chord.notes("C", "aug"), equals(["C", "E", "G#"]));
    });

    test("intervals", () {
      expect(chord.intervals(""), equals(["1P", "3M", "5P"]));
      expect(chord.intervals("maj7"), equals(["1P", "3M", "5P", "7M"]));
      expect(chord.intervals("Cmaj7"), equals(["1P", "3M", "5P", "7M"]));
      expect(chord.intervals("aug"), equals(["1P", "3M", "5A"]));
      expect(
          chord.intervals("C13no5"), equals(["1P", "3M", "7m", "9M", "13M"]));
      expect(chord.intervals("major"), equals([]));
      expect(chord.intervals(), equals([]));
    });

    test("exists", () {
      expect(chord.exists("maj7"), equals(true));
      expect(chord.exists("Cmaj7"), equals(true));
      expect(chord.exists("major"), equals(false));
    });

    test("supsersets", () {
      expect(
          chord.supersets("CMaj7"),
          equals([
            "M13",
            "M13#11",
            "M7#11",
            "M7#9#11",
            "M7add13",
            "M7b9",
            "M9",
            "M9#11"
          ]));
    });

    test("subset", () {
      expect(chord.subsets("CMaj7"), equals(["5", "64", "M"]));
    });

    // test("position", () {
    //   expect(chord.position("g2 c3 e4 b"), equals(2));
    //   expect(chord.position("b e c g"), equals(3));
    // }, skip: 'skip');

    // test("inversion", () {
    //   expect(chord.inversion(1, "C4 maj7"), equals(["E", "G", "B", "C"]));
    //   expect(chord.inversion(0, "e g c"), equals(["C", "E", "G"]));
    //   expect(chord.inversion(1, "e g c"), equals(["E", "G", "C"]));
    //   expect(chord.inversion(2, "e g c"), equals(["G", "C", "E"]));
    //   expect(chord.inversion(0)("b g e d c"), equals(["C", "E", "G", "B", "D"]));
    //   expect(chord.inversion(3, "CMaj7#5"), equals(["B", "C", "E", "G#"]));
    //   expect(chord.inversion(1, "c d e"), equals([]));
    // }, skip: 'skip');

    test("names", () {
      expect(chord.names("100010010001"), equals(["Maj7", "maj7", "M7"]));
      expect(chord.names().length, greaterThan(0));
      expect(chord.names(true).length, greaterThan(chord.names().length));
    });
  });
}
