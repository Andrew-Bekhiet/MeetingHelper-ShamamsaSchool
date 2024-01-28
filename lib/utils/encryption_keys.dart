// coverage:ignore-file
import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/digests/sha3.dart' as sha3;
import 'package:pointycastle/pointycastle.dart' as pc;

class Encryption {
  static String encryptPassword(String q) {
    final hash = _hash(
      256,
      inp: _hash(512, inp: q + r'o$!hP' + '64J^7c') +
          'fKLpdl' +
          'k1px5' +
          'ZwvF^Yu' +
          'Ib9252C0' +
          '8@aQ' +
          '4' +
          'q' +
          'DRZ' +
          'z5h' +
          '2',
    );
    return hash;
    //SHA-3/256( SHA-3/512(password + salt1) + salt2 )
  }

  static String _hash(int byteLength, {required String inp}) {
    final bytes = utf8.encode(inp);
    // return sc.HashCrypt(algo: algo).hash(inp: inp);
    final pc.Digest digest = sha3.SHA3Digest(byteLength);
    final value = digest.process(Uint8List.fromList(bytes));
    return base64.encode(value);
  }
}
