library md_proc.entities;

import './generators/entities.dart';

part 'package:md_proc/entities.g.dart';

/// List of all exiting html entities
@Entities()
final Map<String, String> htmlEntities = _$htmlEntities;

RegExp _re = new RegExp(
    "&(?:" + htmlEntities.keys.join(";|") + ";|#[xX][\\da-fA-F]+;|#\\d+;)");

String decodeEntities(String str) => str.replaceAllMapped(_re, (match) {
      String str = match.group(0);
      if (str[1] == "#") {
        if (str[2] == "X" || str[2] == "x") {
          return new String.fromCharCode(
              int.parse(str.substring(3, str.length - 1), radix: 16));
        }
        return new String.fromCharCode(
            int.parse(str.substring(2, str.length - 1), radix: 10));
      }
      return htmlEntities[str.substring(1, str.length)];
    });
