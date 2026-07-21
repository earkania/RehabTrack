class HealthTemplate {
  final int? id;
  final String name;
  final String description;
  final String configurationJson;

  const HealthTemplate({
    this.id,
    required this.name,
    required this.description,
    required this.configurationJson,
  });

  HealthTemplate copyWith({
    int? id,
    String? name,
    String? description,
    String? configurationJson,
  }) {
    return HealthTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      configurationJson:
          configurationJson ?? this.configurationJson,
    );
  }
}
