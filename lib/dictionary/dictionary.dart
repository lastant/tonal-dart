import 'package:node_shims/node_shims.dart';

/**
 * [![npm version](https://img.shields.io/npm/v/tonal-dictionary.svg)](https://www.npmjs.com/package/tonal-dictionary)
 *
 * `tonal-dictionary` contains a dictionary of musical scales and chords
 *
 * This is part of [tonal](https://www.npmjs.com/package/tonal) music theory library.
 *
 * @example
 * // es6
 * import * as Dictionary from "tonal-dictionary"
 * // es5
 * const Dictionary = require("tonal-dictionary")
 *
 * @example
 * Dictionary.chord("Maj7") // => ["1P", "3M", "5P", "7M"]
 *
 *  Dictionary
 */
import 'data/chords.dart';
import 'data/scales.dart';
import '../pcset/pcset.dart' as pcs;

class Dictionary {
  var keys;
  var data = {};
  var index = {};
  var allKeys;

  Dictionary(Map raw) {
    keys = raw.keys.toList()..sort();

    keys.forEach((key) {
      final ivls = raw[key][0].split(" ");
      final alias = (raw[key] as List).asMap()[1];
      final chr = pcs.chroma(ivls);

      add(key, ivls, chr);
      if (truthy(alias)) alias.forEach((a) => add(a, ivls, chr));
    });

    allKeys = data.keys.toList()..sort();
  }

  list(name) => data[name];

  add(name, ivls, chroma) {
    data[name] = ivls;
    index[chroma] = index[chroma] ?? [];
    index[chroma].add(name);
  }

  names([p]) {
    if (p is String)
      return List.from(index[p] ?? []);
    else
      return List.from(p == true ? allKeys : keys);
  }

  @override
  noSuchMethod(Invocation invocation) {
    if (invocation.isMethod) return data[invocation.positionalArguments[0]];
  }
}

class Combine {
  var a, b;

  Combine(this.a, this.b);

  list(name) => a(name) ?? b(name);

  names([p]) => concat([a.names(p), b.names(p)]);
}

/**
 * A dictionary of scales: a function that given a scale name (without tonic)
 * returns an array of intervals
 *
 * @function
 * 
 * 
 * @example
 * import { scale } from "tonal-dictionary"
 * scale("major") // => ["1P", "2M", ...]
 * scale.names(); // => ["major", ...]
 */
final scale = Dictionary(sdata);

/**
 * A dictionary of chords: a function that given a chord type
 * returns an array of intervals
 *
 * @function
 * 
 * 
 * @example
 * import { chord } from "tonal-dictionary"
 * chord("Maj7") // => ["1P", "3M", ...]
 * chord.names(); // => ["Maj3", ...]
 */
final chord = Dictionary(cdata);
final pcset = Combine(scale, chord);
