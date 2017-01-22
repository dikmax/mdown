library mdown.entities;

import 'dart:collection';

import './generators/entities.dart';

part 'entities.g.dart';

/// List of all exiting html entities
@Entities('https://html.spec.whatwg.org/entities.json')
final Map<String, String> htmlEntities = _$htmlEntities;
