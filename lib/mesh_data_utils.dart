import 'dart:io' show Platform;

import 'package:graphist/graphist.dart';
import 'package:n_triples_db/n_triples_db.dart';
import 'package:n_triples_parser/n_triple_types.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tuple/tuple.dart';

import 'mesh_data_nodes.dart';
import 'mesh_data_relations.dart';

class MeSHDataUtils {
  static final _db = Platform.environment.containsKey("MeSH_SQLite_DB")
      ? NTriplesDb(sqlite3.open(Platform.environment["MeSH_SQLite_DB"]!))
      : null;

  static Iterable<MeSHDataNode> searchForTerm(
    String value, {
    int limit = 0,
    int offset = 0,
  }) {
    final terms = _db!.searchTermsByValue(value, limit: limit, offset: offset);
    return terms.map<MeSHDataNode>((term) {
      switch (term.item2.termType) {
        case NTripleTermType.iri:
          return MeSHDataIriNode(uuid: term.item1, iri: term.item2.value);
        case NTripleTermType.literal:
          return MeSHDataLiteralNode(
            uuid: term.item1,
            value: term.item2.value,
            dataType: term.item2.dataType,
            languageTag: term.item2.languageTag,
          );
        case NTripleTermType.blankNode:
          return MeSHDataBlankNode(uuid: term.item1, value: term.item2.value);
        case null:
          throw "termType is null for $term";
      }
    });
  }

  static Tuple2<MeSHDataLinksRelation, MeSHDataNode> _relativesFromNSPO(
    Node node, {
    String? subjectUuid,
    String? objectUuid,
    required String predicateUuid,
  }) {
    if ((subjectUuid != null && objectUuid != null) ||
        (subjectUuid == null && objectUuid == null)) {
      throw "You must provide either subject or object.";
    }

    final soUuid = subjectUuid ?? objectUuid;

    final so = _db!.selectNTripleTerm(soUuid!);
    MeSHDataNode soNode;
    switch (so!.termType) {
      case NTripleTermType.iri:
        soNode = MeSHDataIriNode(uuid: soUuid, iri: so.value);
        break;
      case NTripleTermType.literal:
        soNode = MeSHDataLiteralNode(
          uuid: soUuid,
          value: so.value,
          dataType: so.dataType,
          languageTag: so.languageTag,
        );
        break;
      case NTripleTermType.blankNode:
        soNode = MeSHDataBlankNode(
          uuid: soUuid,
          value: so.value,
        );
        break;
      case null:
        throw "null termType";
    }

    final predicate = _db!.selectNTripleTerm(predicateUuid);
    final predicateRel = MeSHDataLinksRelation(
      subjectUuid != null ? soNode.id : node.id,
      subjectUuid != null ? node.id : soNode.id,
      predicate!.value,
    );

    return Tuple2(
      predicateRel,
      soNode,
    );
  }

  static Future<Iterable<Tuple2<Relation, Node>>> getNodeRelatives(
    MeSHDataNode node,
  ) async {
    final results = <Tuple2<Relation, Node>>[];

    results.addAll(
      _db!.getSubjectsAndPredicates(node.uuid, limit: 50).map(
            (sp) => _relativesFromNSPO(
              node,
              subjectUuid: sp.item1,
              predicateUuid: sp.item2,
            ),
          ),
    );

    results.addAll(
      _db!.getPredicatesAndObjects(node.uuid, limit: 50).map(
            (po) => _relativesFromNSPO(
              node,
              predicateUuid: po.item1,
              objectUuid: po.item2,
            ),
          ),
    );

    return results;
  }
}
