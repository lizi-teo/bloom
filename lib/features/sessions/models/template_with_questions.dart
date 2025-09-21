import 'template.dart';
import 'question.dart';

class TemplateWithQuestions {
  final Template template;
  final List<Question> questions;

  const TemplateWithQuestions({
    required this.template,
    required this.questions,
  });

  factory TemplateWithQuestions.fromJson(Map<String, dynamic> json) {
    return TemplateWithQuestions(
      template: Template.fromJson(json),
      questions: [],
    );
  }

  factory TemplateWithQuestions.fromQueryResults(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      throw Exception('No template data found');
    }

    final firstRow = results.first;
    final template = Template(
      templateId: firstRow['template_id'] as int?,
      templateName: firstRow['template_name'] as String?,
      imageUrl: firstRow['image_url'] as String?,
    );

    final questions = results
        .where((row) => row['question_id'] != null)
        .map((row) => Question.fromJson(row))
        .toList();

    return TemplateWithQuestions(
      template: template,
      questions: questions,
    );
  }
}