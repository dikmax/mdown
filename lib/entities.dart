library md_proc.entities;

import 'dart:collection';
import './generators/entities.dart';

part 'entities.g.dart';

/// List of all exiting html entities
@Entities()
final Map<String, String> htmlEntities = _$htmlEntities;
