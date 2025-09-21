class Template {
  final int? templateId;
  final String? templateName;
  final String? imageUrl;

  const Template({
    this.templateId,
    this.templateName,
    this.imageUrl,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      templateId: json['template_id'] as int?,
      templateName: json['template_name'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (templateId != null) 'template_id': templateId,
      if (templateName != null) 'template_name': templateName,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  @override
  String toString() => templateName ?? 'Unknown Template';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Template && 
           other.templateId == templateId &&
           other.templateName == templateName &&
           other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => Object.hash(templateId, templateName, imageUrl);
}