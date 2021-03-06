import 'package:test/test.dart';

import '../distance.dart' as dist;

void main() {
  final tr = dist.transpose;

  final lift = (fn) => (arr) => arr.split(" ").map(fn).join(" ");

  group("distance", () {
    group("find intervals between notes", () {
      test("interval between notes", () {
        var fromC3 = lift(dist.interval("C3"));
        expect(fromC3("C3 e3 e4 c2 e2"), equals("1P 3M 10M -8P -6m"));
      });

      test("intervals between pitch classes are always ascending", () {
        expect(dist.interval("C", "D"), equals("2M"));

        var fromC = lift(dist.interval("C"));
        expect(fromC("c d e f g a b"), equals("1P 2M 3M 4P 5P 6M 7M"));

        var fromG = lift(dist.interval("G"));
        expect(fromG("c d e f g a b"), equals("4P 5P 6M 7m 1P 2M 3M"));
      });
      test("note types can not be mixed", () {
        expect(dist.interval("C", "C2"), equals(null));
        expect(dist.interval("C2", "C"), equals(null));
      });
    });

    test("semitones", () {
      expect(dist.semitones("C3", "G#3"), equals(8));
      expect(dist.semitones("C4", "A3"), equals(-3));

      final fromC = lift(dist.semitones("C"));
      expect(fromC("C D E F G A B"), equals("0 2 4 5 7 9 11"));

      final fromB = lift(dist.semitones("B"));
      expect(fromB("C D E F G A B"), equals("1 3 5 6 8 10 0"));

      expect(dist.semitones("blah", "C3"), equals(null));
    });

    group("transposition", () {
      test("transpose pitch classes by intervals", () {
        final trFromBb = lift(dist.transpose("Bb"));
        expect(trFromBb("P1 M3 P5 M7"), equals("Bb D F A"));
      });

      test("transpose notes by intervals", () {
        final trFromBb2 = lift(dist.transpose("Bb2"));
        expect(trFromBb2("P1 M3 P5 M7"), equals("Bb2 D3 F3 A3"));
      });

      test("tranpose note by descending intervas", () {
        final trFromBb = lift(dist.transpose("Bb"));
        expect(trFromBb("P-1 M-3 P-5 M-7"), equals("Bb Gb Eb Cb"));
      });

      test("transpose by interval", () {
        final trBy3M = lift(dist.transposeBy("3M"));
        expect(trBy3M("c2 d3 f4 g5"), equals("E2 F#3 A4 B5"));
      });

      test("transpose nulls", () {
        expect(tr("M3", "blah"), equals(null));
        expect(tr("blah", "C2"), equals(null));
        expect(tr(null, null), equals(null));
      });

      test("transpose by descending intervals", () {
        final trDescM2 = lift(dist.transposeBy("-2M"));
        expect(trDescM2("c2 d3 f4 g5"), equals("Bb1 C3 Eb4 F5"));
      });

      test("transpose edge cases", () {
        final fromC2 = lift(dist.transpose("C2"));

        expect(fromC2("1d 1P 1A"), equals("Cb2 C2 C#2"));
        expect(fromC2("-1d -1P -1A"), equals("C#2 C2 Cb2"));
        expect(fromC2("2d 2m 2M 2A"), equals("Dbb2 Db2 D2 D#2"));
        expect(fromC2("-2d -2m -2M -2A"), equals("B#1 B1 Bb1 Bbb1"));
        expect(fromC2("4dd 4d 4P 4A 4AA"), equals("Fbb2 Fb2 F2 F#2 F##2"));
        expect(fromC2("5P -5P 5A -5A"), equals("G2 F1 G#2 Fb1"));
        expect(fromC2("6M -6M 6m -6m"), equals("A2 Eb1 Ab2 E1"));
      });
    });

    group("transpose intervals", () {
      test("add ascending intervals ", () {
        final add3M = lift(dist.add("3M"));
        expect(add3M("1P 2M 3M 4P 5P"), equals("3M 4A 5A 6M 7M"));
      });

      test("add descending intervals", () {
        final addDescM2 = lift(dist.add("-2M"));
        expect(addDescM2("1P 2M 3M 4P 5P"), equals("-2M 1P 2M 3m 4P"));
        expect(addDescM2("-5P -4P -3M -2M 1P"), equals("-6M -5P -4A -3M -2M"));
      });
      test("subtract intervals", () {
        expect(dist.subtract("5P", "3M"), equals("3m"));
        expect(dist.subtract("3M", "5P"), equals("-3m"));
      });
    });

    group("fifths", () {
      test("transpose fifths", () {
        expect([0, 1, 2, 3, 4, 5, 6, 7].map(dist.trFifths("C")).join(" "),
            equals("C G D A E B F# C#"));
        expect([0, 1, 2, 3, 4, 5, 6, 7].map(dist.trFifths("C4")).join(" "),
            equals("C G D A E B F# C#"));
      });

      test("distance in fifths", () {
        expect(dist.fifths("C", "G"), equals(1));
        expect(dist.fifths("G", "D"), equals(1));
        expect(dist.fifths("C", "C#"), equals(7));
      });
    });
  });
}
