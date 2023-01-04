import 'package:graphist/graphist.dart';
import 'package:tuple/tuple.dart';

import 'mesh_data_utils.dart';

enum MeSHDataNodeType {
  iri,
  literal,
  blank,
}

abstract class MeSHDataNode extends Node {
  String uuid;
  MeSHDataNodeType meSHDataNodeType;

  MeSHDataNode({
    required this.uuid,
    required this.meSHDataNodeType,
    required Map<String, dynamic> properties,
    required String labelProperty,
    required String? urlProperty,
  }) : super(
          type: meSHDataNodeType.toString(),
          properties: properties,
          labelProperty: labelProperty,
          uniqueProperty: "uuid",
          urlProperty: urlProperty,
        );

  @override
  Future<Iterable<Tuple2<Relation, Node>>> get relatives async {
    return MeSHDataUtils.getNodeRelatives(this);
  }
}

class MeSHDataIriNode extends MeSHDataNode {
  String iri;

  MeSHDataIriNode({
    required String uuid,
    required this.iri,
  }) : super(
          uuid: uuid,
          meSHDataNodeType: MeSHDataNodeType.iri,
          properties: {
            "uuid": uuid,
            "iri": iri,
          },
          labelProperty: "iri",
          urlProperty: "iri",
        );
}

class MeSHDataLiteralNode extends MeSHDataNode {
  String value;
  String dataType;
  String languageTag;

  MeSHDataLiteralNode({
    required String uuid,
    required this.value,
    required this.dataType,
    required this.languageTag,
  }) : super(
          uuid: uuid,
          meSHDataNodeType: MeSHDataNodeType.literal,
          properties: {
            "uuid": uuid,
            "value": value,
            "dataType": dataType,
            "languageTag": languageTag,
          },
          labelProperty: "value",
          urlProperty: null,
        );
}

class MeSHDataBlankNode extends MeSHDataNode {
  String value;

  MeSHDataBlankNode({
    required String uuid,
    required this.value,
  }) : super(
          uuid: uuid,
          meSHDataNodeType: MeSHDataNodeType.blank,
          properties: {
            "uuid": uuid,
            "value": value,
          },
          labelProperty: "value",
          urlProperty: null,
        );
}
