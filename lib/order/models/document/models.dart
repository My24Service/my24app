class OrderDocument {
  final int id;
  final int orderId;
  final String name;
  final String description;
  final String file;
  final String url;

  OrderDocument({
    this.id,
    this.orderId,
    this.name,
    this.description,
    this.file,
    this.url,
  });

  factory OrderDocument.fromJson(Map<String, dynamic> parsedJson) {
    return OrderDocument(
      id: parsedJson['id'],
      orderId: parsedJson['order'],
      name: parsedJson['name'],
      description: parsedJson['description'],
      file: parsedJson['file'],
      url: parsedJson['url'],
    );
  }
}

class OrderDocuments {
  final int count;
  final String next;
  final String previous;
  final List<OrderDocument> results;

  OrderDocuments({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory OrderDocuments.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<OrderDocument> results = list.map((i) => OrderDocument.fromJson(i)).toList();

    return OrderDocuments(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}
