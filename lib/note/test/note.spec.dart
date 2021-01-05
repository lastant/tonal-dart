import 'package:test/test.dart';
import "../note.dart" as note;

void main() {
  Function dollar = (str) => str.split(" ");
  Function map = (fn, String str) => str.split(" ").map(fn).toList();

  group("tokenize", () {
    test("test", () {
      expect(note.tokenize("Cbb5 major"), equals(["C", "bb", "5", "major"]));
    });
    test("test", () {
      expect(note.tokenize("Ax"), equals(["A", "##", "", ""]));
    });
    test("test", () {
      expect(note.tokenize("CM"), equals(["C", "", "", "M"]));
    });
    test("test", () {
      expect(note.tokenize("maj7"), equals(["", "", "", "maj7"]));
    });
    test("test", () {
      expect(note.tokenize(""), equals(["", "", "", ""]));
    });
    test("test", () {
      expect(note.tokenize("bb"), equals(["B", "b", "", ""]));
    });
    test("test", () {
      expect(note.tokenize("##"), equals(["", "##", "", ""]));
    });
    test("test", () {
      expect(note.tokenize(3), equals(["", "", "", ""]));
    });
    //@ts-ignore
    test("test", () {
      expect(note.tokenize(false), equals(["", "", "", ""])); //@ts-ignore
    });
    test("test", () {
      expect(note.tokenize(null), equals(["", "", "", ""]));
    });
  });

  group("name", () {
    var names = map(note.name, "c fx dbb bbb c##-1 fbb6");
    test("test", () {
      expect(names,
          equals(["C", "F##", "Dbb", "Bbb", "C##-1", "Fbb6"])); //@ts-ignore
    });

    test("test", () {
      expect(note.name("blah"), equals(null));
    });
    test("test", () {
      expect(note.name(), equals(null));
    });
  });

  group("build", () {
    test("test", () {
      expect(note.build({'step': 1, 'alt': -1}), equals("Db"));
    });
    test("test", () {
      expect(note.build({'step': 2, 'alt': 1, 'oct': null}), equals("E#"));
    });
    test("test", () {
      expect(note.build({'step': 5}), equals("A"));
    });
    test("test", () {
      expect(note.build({'step': -1}), equals(null));
    });
    test("test", () {
      expect(note.build({'step': 8}), equals(null));
    });
    test("test", () {
      expect(note.build({}), equals(null)); //@ts-ignor)e
    });
    test("test", () {
      expect(note.build("blah"), equals(null));
    });
  });

  group("from", () {
    test("test", () {
      expect(note.from({'step': 1, 'alt': -1}), equals("Db"));
    });
    test("test", () {
      expect(note.from({'step': 2, 'alt': 1, 'oct': null}), equals("E#"));
    });
    test("test", () {
      expect(note.from({'step': 5}), equals("A"));
    });
    test("test", () {
      expect(note.from({'step': -1}), equals(null));
    });
    test("test", () {
      expect(note.from({'step': 8}), equals(null));
    });
    test("test", () {
      expect(note.from({}), equals(null));
    });
    test("test", () {
      expect(note.from(), equals(null));
    });
    //@ts-ignore
    test("test", () {
      expect(note.from("blah"), equals(null));
    });
    test("test", () {
      expect(note.from({'alt': 0}, "C#3"), equals("C3"));
    });
    test("test", () {
      expect(note.from({'step': 2, 'oct': 3}, "B#"), equals("E#3"));
    });
  });

  group("names", () {
    test("test", () {
      expect(note.names(),
          equals(dollar("C C# Db D D# Eb E F F# Gb G G# Ab A A# Bb B")));
    });
    test("test", () {
      expect(note.names(" "), equals(dollar("C D E F G A B")));
    });
    test("test", () {
      expect(note.names("b "), equals(dollar("C Db D Eb E F Gb G Ab A Bb B")));
    });
    test("test", () {
      expect(note.names("# "), equals(dollar("C C# D D# E F F# G G# A A# B")));
    });
    test("test", () {
      expect(note.names(" b#"), equals(note.names()));
    });
  });

  group("props", () {
    test("test", () {
      expect(
          note.props("C#3"),
          equals({
            'acc': "#",
            'alt': 1,
            'chroma': 1,
            'letter': "C",
            'name': "C#3",
            'oct': 3,
            'octStr': "3",
            'pc': "C#",
            'step': 0,
            'midi': 49,
            'freq': 138.59131548843604
          }));
    });
    test("test", () {
      expect(
          note.props("Bb-20"),
          equals({
            'acc': "b",
            'alt': -1,
            'chroma': 10,
            'freq': 0.000027785525412445636,
            'letter': "B",
            'midi': -218,
            'name': "Bb-20",
            'oct': -20,
            'octStr': "-20",
            'pc': "Bb",
            'step': 6 // @ts-ignore
          }));
    });
    test("test", () {
      expect(note.props("major"), equals(note.props()));
    });
  });

  group("oct", () {
    var octs = map(note.oct, "a-2 b-1 c0 d1 e2 f3 g4 a5 b6 c7 d8 c9 d10");
    test("test", () {
      expect(octs, equals([-2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]));
    });
    test("test", () {
      expect(note.oct("c"), equals(null));
    });
    test("test", () {
      expect(note.oct("blah"), equals(null));
    });
  });

  group("midi", () {
    var midis =
        "c4 d4 e4 f4 g4 a4 b4 c4 c-1 c-2".split(" ").map(note.midi).toList();
    test("test", () {
      expect(midis, equals([60, 62, 64, 65, 67, 69, 71, 60, 0, null]));
    });
    test("test", () {
      expect(note.midi("C"), equals(null));
    });
    test("test", () {
      expect(note.midi("bla"), equals(null));
    });
    //@ts-ignore    //@ts-ignore
    test("test", () {
      expect(note.midi(false), equals(null));
    });
  });

  group("fromMidi", () {
    var notes = [60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72];
    test("test", () {
      expect(notes.map(note.fromMidi).join(" "),
          equals("C4 Db4 D4 Eb4 E4 F4 Gb4 G4 Ab4 A4 Bb4 B4 C5"));
    });
    test("test", () {
      expect(notes.map((n) => note.fromMidi(n, true)).join(" "),
          equals("C4 C#4 D4 D#4 E4 F4 F#4 G4 G#4 A4 A#4 B4 C5"));
    });
    test("test", () {
      expect(note.fromMidi(60), equals("C4"));
    });
  });

  group("midi accepts valid MIDI note numbers", () {
    test("test", () {
      expect(note.midi(60), equals(60));
    });
    test("test", () {
      expect(note.midi("60"), equals(60));
    });
    test("test", () {
      expect(note.midi(0), equals(0));
    });
    test("test", () {
      expect(note.midi(-1), equals(null));
    });
    test("test", () {
      expect(note.midi(128), equals(null));
    });
  });

  group("test", () {
    test("freq", () {
      expect(note.freq("A4"), equals(440));
    });
    test("freq", () {
      expect(note.freq(69), equals(440));
    });
    test("test", () {
      expect(note.freq("bla"), equals(null));
    });
  });

  group("test", () {
    test("test", () {
      expect(note.freqToMidi(220), equals(57));
    });
    test("test", () {
      expect(note.freqToMidi(261.62), equals(60));
    });
    test("test", () {
      expect(note.freqToMidi(261), equals(59.96));
    });
  });

  group("test", () {
    test("midiToFreq", () {
      expect((note.midiToFreq(57)).floor(), equals(220));
    });
    test("midiToFreq", () {
      expect((note.midiToFreq(60)).floor(), equals(261));
    });
    test("test", () {
      expect(note.midiToFreq(57, 440), equals(220));
    });
  });

  group("chroma", () {
    var chromas =
        "Cb C Db D Eb E Fb F Gb G Ab A Bb B".split(" ").map(note.chroma);
    test("test", () {
      expect(chromas, equals([11, 0, 1, 2, 3, 4, 4, 5, 6, 7, 8, 9, 10, 11]));
    });
    test("test", () {
      expect("C C# D D# E E# F F# G G# A A# B B#".split(" ").map(note.chroma),
          equals([0, 1, 2, 3, 4, 5, 5, 6, 7, 8, 9, 10, 11, 0]));
    });
  });

  group("pc", () {
    final pcs = map(note.pc, "a b0 d2 e# fb3 g###4 bbbb5");
    test("pc", () {
      expect(pcs, equals(["A", "B", "D", "E#", "Fb", "G###", "Bbbb"]));
    });
    test("pc", () {
      expect(note.pc("blah"), equals(null));
    });
    test("test", () {
      expect(note.pc("h"), equals(null));
    });
  });

  group("altToAcc", () {
    final accs = [-4, -3, -2, -1, 0, 1, 2, 3, 4].map(note.altToAcc);
    final expected = ["bbbb", "bbb", "bb", "b", "", "#", "##", "###", "####"];
    test("test", () {
      expect(accs, equals(expected));
    });
  });

  group("stepToLetter", () {
    final steps = [0, 1, 2, 3, 4, 5, 6];
    test('test', () {
      expect(steps.map(note.stepToLetter), equals(dollar("C D E F G A B")));
    });
    test("test", () {
      expect(note.stepToLetter(-1), equals(null));
    });
    test("test", () {
      expect(note.stepToLetter(7), equals(null));
    });
  });

  group("simplify", () {
    var notes = dollar("C## C### F##4 Gbbb5 B#4 Cbb4");
    test("test", () {
      expect(notes.map(note.simplify), equals(dollar("D D# G4 E5 C5 Bb3")));
    });
    test("test", () {
      expect(notes.map((n) => note.simplify(n, false)),
          equals(dollar("D Eb G4 E5 C5 A#3")));
    });

    test("test", () {
      expect(note.simplify("C#"), equals("C#"));
    });
    test("test", () {
      expect(note.simplify("C#", false), equals("Db"));
    });
    test("test", () {
      expect(note.simplify("ohhaimark"), equals(null));
    });
  });
}
