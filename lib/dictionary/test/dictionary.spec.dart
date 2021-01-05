/* global describe test expect */
import 'package:test/test.dart';

import '../dictionary.dart' as d;

void main() {
  var DATA = {
    'maj7': [
      "1P 3M 5P 7M",
      ["Maj7"]
    ],
    'm7': ["1P 3m 5P 7m"]
  };

  final arr = (String str) => str.split(" ");

  group("tonal-dictionary", () {
    test("create a dictionary", () {
      final dict = d.Dictionary(DATA);
      expect(dict.list("m7"), equals(["1P", "3m", "5P", "7m"]));
      expect(dict.list("maj7"), equals(["1P", "3M", "5P", "7M"]));
      expect(dict.list("Maj7"), equals(["1P", "3M", "5P", "7M"]));
      expect(dict.list("Maj"), equals(null));
    });

    test("dictionary has keys", () {
      final dict = d.Dictionary(DATA);
      expect(dict.names(), equals(["m7", "maj7"]));
      expect(dict.names(true), equals(["Maj7", "m7", "maj7"]));
    });

    test("scale dictionary", () {
      expect(d.scale.list("major"), equals(arr("1P 2M 3M 4P 5P 6M 7M")));
      expect(
          d.scale.list("bebop minor"), equals(arr("1P 2M 3m 3M 4P 5P 6M 7m")));
      expect(d.scale.names("101011010101"), equals(["major", "ionian"]));
    });

    test("chord dictionary", () {
      expect(d.chord.list("Maj7"), equals(["1P", "3M", "5P", "7M"]));
      expect(d.chord.list("maj7"), equals(["1P", "3M", "5P", "7M"]));
      expect(d.chord.names("100010010001"), equals(["Maj7", "maj7", "M7"]));
    });

    test("pitchset dictionary", () {
      expect(d.pcset.list("Maj7"), equals(["1P", "3M", "5P", "7M"]));
      expect(d.pcset.list("major"), equals(arr("1P 2M 3M 4P 5P 6M 7M")));
      expect(d.pcset.names().length,
          equals(d.scale.names().length + d.chord.names().length));
    });
  });
}
