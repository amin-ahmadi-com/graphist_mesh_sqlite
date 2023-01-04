import 'package:graphist/graphist.dart';

enum MeSHDataRelationType {
  links,
}

class MeSHDataLinksRelation extends Relation {
  String iri;

  MeSHDataLinksRelation(
    String fromNodeId,
    String toNodeId,
    this.iri,
  ) : super(
          type: MeSHDataRelationType.links.toString(),
          properties: {"iri": iri},
          fromNodeId: fromNodeId,
          toNodeId: toNodeId,
          labelProperty: "iri",
        );

  @override
  Map<String, dynamic> get properties => {"iri": iri};
}
