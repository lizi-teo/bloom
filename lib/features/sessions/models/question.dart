class Question {
  final int? questionId;
  final String? question;
  final String? title;
  final String? minLabel;
  final String? maxLabel;
  final int? componentTypeId;

  const Question({
    this.questionId,
    this.question,
    this.title,
    this.minLabel,
    this.maxLabel,
    this.componentTypeId,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionId: json['question_id'] as int?,
      question: json['question'] as String?,
      title: json['title'] as String?,
      minLabel: json['min_label'] as String?,
      maxLabel: json['max_label'] as String?,
      componentTypeId: json['component_type_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (questionId != null) 'question_id': questionId,
      if (question != null) 'question': question,
      if (title != null) 'title': title,
      if (minLabel != null) 'min_label': minLabel,
      if (maxLabel != null) 'max_label': maxLabel,
      if (componentTypeId != null) 'component_type_id': componentTypeId,
    };
  }

  @override
  String toString() => title ?? 'Unknown Question';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && 
           other.questionId == questionId &&
           other.question == question &&
           other.title == title &&
           other.minLabel == minLabel &&
           other.maxLabel == maxLabel &&
           other.componentTypeId == componentTypeId;
  }

  @override
  int get hashCode => Object.hash(questionId, question, title, minLabel, maxLabel, componentTypeId);
}