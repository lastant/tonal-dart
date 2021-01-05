import 'dart:math';

import 'package:node_shims/node_shims.dart';

/**
 * [![npm version](https://img.shields.io/npm/v/tonal-note.svg)](https://www.npmjs.com/package/tonal-note)
 * [![tonal](https://img.shields.io/badge/tonal-note-yellow.svg)](https://www.npmjs.com/browse/keyword/tonal)
 *
 * `tonal-note` is a collection of functions to manipulate musical notes in scientific notation
 *
 * This is part of [tonal](https://www.npmjs.com/package/tonal) music theory library.
 *
 * ## Usage
 *
 * ```js
 * import * as Note from "tonal-note"
 * // or const Note = require("tonal-note")
 * Note.name("bb2") // => "Bb2"
 * Note.chroma("bb2") // => 10
 * Note.midi("a4") // => 69
 * Note.freq("a4") // => 440
 * Note.oct("G3") // => 3
 *
 * // part of tonal
 * const Tonal = require("tonal")
 * // or import Note from "tonal"
 * Tonal.Note.midi("d4") // => 62
 * ```
 *
 * ## Install
 *
 * [![npm install tonal-note](https://nodei.co/npm/tonal-note.png?mini=true)](https://npmjs.org/package/tonal-note/)
 *
 * ## API Documentation
 *
 *  Note
 */

final NAMES = "C C# Db D D# Eb E F F# Gb G G# Ab A A# Bb B".split(" ");

/**
 * Get a list of note names (pitch classes) within a octave
 *
 * 
 * accidentals types: " " means no accidental, "#" means sharps, "b" mean flats,
 * can be combined (see examples)
 * 
 * @example
 * Note.names(" b") // => [ "C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B" ]
 * Note.names(" #") // => [ "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" ]
 */
final names = ([accTypes]) => accTypes is! String
    ? List.from(NAMES)
    : NAMES.where((n) {
        final acc = n.length > 1 ? n[1] : " ";
        return accTypes.indexOf(acc) != -1;
      }).toList();

final SHARPS = names(" #");
final FLATS = names(" b");
final REGEX = new RegExp(r'^([a-gA-G]?)(#{1,}|b{1,}|x{1,}|)(-?\d*)\s*(.*)$');

/**
 * Split a string into tokens related to note parts.
 * It returns an array of strings `[letter, accidental, octave, modifier]`
 *
 * It always returns an array
 *
 * 
 * 
 * @example
 * Note.tokenize("C#2") // => ["C", "#", "2", ""]
 * Note.tokenize("Db3 major") // => ["D", "b", "3", "major"]
 * Note.tokenize("major") // => ["", "", "", "major"]
 * Note.tokenize("##") // => ["", "##", "", ""]
 * Note.tokenize() // => ["", "", "", ""]
 */
tokenize([str]) {
  if (str is! String) str = "";
  final m = REGEX.firstMatch(str);
  // Will never execute

  // if (!m) return null;
  return [
    m.group(1).toUpperCase(),
    m.group(2).replaceAll('x', "##"),
    m.group(3),
    m.group(4)
  ];
}

final NO_NOTE = {
  'pc': null,
  'name': null,
  'step': null,
  'alt': null,
  'oct': null,
  'octStr': null,
  'chroma': null,
  'midi': null,
  'freq': null
};

final SEMI = [0, 2, 4, 5, 7, 9, 11];
final properties = (str) {
  final tokens = tokenize(str);
  // Will never execute
  // if (tokens === null) return NO_NOTE;
  if (tokens[0] == "" || tokens[3] != "") return NO_NOTE;
  final letter = tokens[0], acc = tokens[1], octStr = tokens[2];
  final p = {
    'letter': letter,
    'acc': acc,
    'octStr': octStr,
    'pc': letter + acc,
    'name': letter + acc + octStr,
    'step': (letter.codeUnitAt(0) + 3) % 7,
    'alt': acc.length > 0 && acc[0] == "b" ? -acc.length : acc.length,
    'oct': octStr.length > 0 ? int.parse(octStr) : null,
    'chroma': 0,
    'midi': null,
    'freq': null
  };
  p['chroma'] = (SEMI[p['step']] + p['alt'] + 120) % 12;
  p['midi'] = p['oct'] != null
      ? SEMI[p['step']] + p['alt'] + 12 * (p['oct'] + 1)
      : null;
  p['freq'] = midiToFreq(p['midi']);
  return p;
};

// function memo
final memo = ([fn, Map cache]) => ([str]) {
      if (cache == null) cache = {};
      return cache[str] ?? (cache[str] = fn(str));
    };

/**
 * Get note properties. It returns an object with the following information:
 *
 * - name {string}: the note name. The letter is always in uppercase
 * - letter {string}: the note letter, always in uppercase
 * - acc {string}: the note accidentals
 * - octave {Number}: the octave or null if not present
 * - pc {string}: the pitch class (letter + accidentals)
 * - step {Number}: number equivalent of the note letter. 0 means C ... 6 means B.
 * - alt {Number}: number equivalent of accidentals (negative are flats, positive sharps)
 * - chroma {Number}: number equivalent of the pitch class, where 0 is C, 1 is C# or Db, 2 is D...
 * - midi {Number}: the note midi number (IMPORTANT! it can be outside 0 to 127 range)
 * - freq {Number}: the frequency using an equal temperament at 440Hz
 *
 * This function *always* returns an object with all this properties, but if it"s
 * not a valid note all properties will be null.
 *
 * The returned object can"t be mutated.
 *
 * 
 * 
 * set to null if not valid note)
 * @example
 * Note.props("fx-3").name // => "F##-3"
 * Note.props("invalid").name // => null
 * Note.props("C#3").oct // => 3
 * Note.props().oct // => null
 */
final props = memo(properties);

/**
 * Given a note name, return the note name or null if not valid note.
 * The note name will ALWAYS have the letter in upercase and accidentals
 * using # or b
 *
 * Can be used to test if a string is a valid note name.
 *
 * @function
 * 
 * 
 *
 * @example
 * Note.name("cb2") // => "Cb2"
 * ["c", "db3", "2", "g+", "gx4"].map(Note.name) // => ["C", "Db3", null, null, "G##4"]
 */
final name = ([str]) => props(str)['name'];

/**
 * Get pitch class of a note. The note can be a string or a pitch array.
 *
 * @function
 * 
 * 
 * @example
 * Note.pc("Db3") // => "Db"
 * ["db3", "bb6", "fx2"].map(Note.pc) // => [ "Db", "Bb", "F##"]
 */
final pc = (str) => props(str)['pc'];

final isMidiRange = (m) => m is num ? m >= 0 && m <= 127 : false;

/**
 * Get the note midi number. It always return a number between 0 and 127
 *
 * @function
 * 
 * 
 * @example
 * Note.midi("C4") // => 60
 * Note.midi(60) // => 60
 * @see midi.toMidi
 */
final midi = (note) {
  if (note is! num && note is! String) {
    return null;
  }
  final midi = props(note)['midi'];
  final value = midi ?? (midi == 0 ? midi : num.parse(note.toString()));
  return isMidiRange(value) ? value : null;
};

/**
 * Get the frequency from midi number
 *
 * 
 * 
 * 
 */
final midiToFreq = (midi, [tuning = 440]) =>
    midi is num ? pow(2, (midi - 69) / 12) * tuning : null;

/**
 * Get the frequency of a note
 *
 * @function
 * 
 * 
 * @example
 * Note.freq("A4") // => 440
 * Note.freq(69) // => 440
 */
final freq = (note) => props(note)['freq'] ?? midiToFreq(note);

final L2 = log(2);
final L440 = log(440);
/**
 * Get the midi number from a frequency in hertz. The midi number can
 * contain decimals (with two digits precission)
 *
 * 
 * 
 * @example
 * Note.freqToMidi(220)); //=> 57;
 * Note.freqToMidi(261.62)); //=> 60;
 * Note.freqToMidi(261)); //=> 59.96;
 */
final freqToMidi = (num freq) {
  final v = (12 * (log(freq) - L440)) / L2 + 69;
  return (v * 100).round() / 100;
};

/**
 * Return the chroma of a note. The chroma is the numeric equivalent to the
 * pitch class, where 0 is C, 1 is C# or Db, 2 is D... 11 is B
 *
 * 
 * 
 * @example
 * Note.chroma("Cb") // => 11
 * ["C", "D", "E", "F"].map(Note.chroma) // => [0, 2, 4, 5]
 */
final chroma = (str) => props(str)['chroma'];

/**
 * Get the octave of the given pitch
 *
 * @function
 * 
 * 
 * @example
 * Note.oct("C#4") // => 4
 * Note.oct("C") // => null
 * Note.oct("blah") // => undefined
 */
final oct = (str) => props(str)['oct'];

const LETTERS = "CDEFGAB";
/**
 * Given a step number return it's letter (0 = C, 1 = D, 2 = E)
 * 
 * 
 * @example
 * Note.stepToLetter(3) // => "F"
 */
final stepToLetter = (num step) => step >= 0 && step < 7 ? LETTERS[step] : null;

final fillStr = (String s, num n) => List.filled(n + 1, '').join(s);
final numToStr = (n, op) => n is! num ? "" : op(n);

/**
 * Given an alteration number, return the accidentals
 * 
 * 
 * @example
 * Note.altToAcc(-3) // => "bbb"
 */
final altToAcc = ([num alt]) =>
    numToStr(alt, (alt) => (alt < 0 ? fillStr("b", -alt) : fillStr("#", alt)));

/**
 * Creates a note name in scientific notation from note properties,
 * and optionally another note name.
 * It receives an object with:
 * - step: the note step (0 = C, 1 = D, ... 6 = B)
 * - alt: (optional) the alteration. Negative numbers are flats, positive sharps
 * - oct: (optional) the octave
 *
 * Optionally it receives another note as a "base", meaning that any prop not explicitly
 * received on the first parameter will be taken from that base note. That way it can be used
 * as an immutable "set" operator for a that base note
 *
 * @function
 * 
 * 
 * the result of applying the given props to this note.
 * 
 * @example
 * Note.from({ step: 5 }) // => "A"
 * Note.from({ step: 1, acc: -1 }) // => "Db"
 * Note.from({ step: 2, acc: 2, oct: 2 }) // => "E##2"
 * Note.from({ step: 7 }) // => null
 * Note.from({alt: 1, oct: 3}, "C4") // => "C#3"
 */
final dynamic from = ([fromProps = const {}, baseNote = null]) {
  Map map = truthy(baseNote)
      ? {...props(baseNote), ...fromProps}
      : fromProps is Map ? fromProps : {};
  var step = map['step'], alt = map['alt'], oct = map['oct'];
  if (step is! num) return null;
  // if (typeof alt !== "number") return null
  final letter = stepToLetter(step);
  if (falsey(letter)) return null;
  final pc = letter + altToAcc(alt);
  return truthy(oct) || oct == 0 ? pc + oct.toString() : pc;
};

/**
 * Deprecated. This is kept for backwards compatibility only.
 * Use Note.from instead
 */
final build = from;

/**
 * Given a midi number, returns a note name. The altered notes will have
 * flats unless explicitly set with the optional `useSharps` parameter.
 *
 * @function
 * 
 * 
 * 
 * @example
 * Note.fromMidi(61) // => "Db4"
 * Note.fromMidi(61, true) // => "C#4"
 * // it rounds to nearest note
 * Note.fromMidi(61.7) // => "D4"
 */
fromMidi(n, [sharps = false]) {
  n = (n).round();
  final List pcs = sharps == true ? SHARPS : FLATS;
  final pc = pcs[n % 12];
  final o = (n / 12).floor() - 1;
  return pc + o.toString();
}

/**
 * Simplify the note: find an enhramonic note with less accidentals.
 *
 * 
 * 
 * to ensure the returned note has the same accidental types that the given note
 * 
 * @example
 * Note.simplify("C##") // => "D"
 * Note.simplify("C###") // => "D#"
 * Note.simplify("C###", false) // => "Eb"
 * Note.simplify("B#4") // => "C5"
 */
final simplify = (note, [sameAcc = true]) {
  var map = props(note);
  var alt = map['alt'], chroma = map['chroma'], midi = map['midi'];

  if (chroma == null) return null;
  final alteration = alt;
  final useSharps = sameAcc == false ? alteration < 0 : alteration > 0;
  return midi == null
      ? pc(fromMidi(chroma, useSharps))
      : fromMidi(midi, useSharps);
};

/**
 * Get the simplified and enhramonic note of the given one.
 *
 * 
 * 
 * @example
 * Note.enharmonic("Db") // => "C#"
 * Note.enhramonic("C") // => "C"
 */
final enharmonic = (note) => simplify(note, false);
