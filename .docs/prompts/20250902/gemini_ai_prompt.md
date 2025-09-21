Objective
Generate code for a dynamic results page in a flutter application. The page should conditionally display different ui components based on the type of question in a survey template.

Input
The ai will receive the following data:

A template identifier (e.g., retrospective_template_id).

Questions and their properties (specifically component_type) from a database table.

User responses associated with each question.

The file paths for the two ui components: lib/components/molecules/sentiment_answers_card.dart and lib/components/molecules/results_answers_card.dart.

Task
The ai's task is to create the logic for the dynamic results page. This involves iterating through each question and its associated data and performing the following actions:

Render the sentiment_answers_card.dart: For any question where the component_type is text, the code should instantiate and display the sentiment_answers_card. This card will be responsible for showing the sentiment analysis results for that specific question.

Render the results_answers_card.dart: For all other question types (e.g., sliders), the code should instantiate and display the results_answers_card.

Conditional logic: The code must contain conditional logic that correctly identifies the question type and renders only the content for each question. The results_answers_card should hide any questions that are of the text type.

= = = = 


Objective: Analyze user feedback from a single session to derive sentiment-based metrics and key insights.

Input:
A collection of raw, open-ended feedback strings from multiple users for a single session. This feedback is provided as a single string.
The total number of users who provided feedback on this specific question (this may be fewer than the total number of participants in the session).

Task:
Perform a comprehensive sentiment analysis on the provided user feedback. The analysis should produce two distinct sentiment scores and a summary of key findings.

Output:
Overall sentiment score: A value from 0 to 100 representing the overall sentiment of the entire body of feedback. A score of 0 is the most negative, and 100 is the most positive. 
The average sentiment score of each individual user's feedback. Calculate this by assigning a sentiment score (0-100) to each individual user response and then averaging those scores. example The result: The ai would then calculate the average: (95 + 55 + 20) / 3 = 56.67. This would be the average sentiment score of open ended questions.
The results are shown using the molecule lib/components/molecules/sentiment_answers_card.dart

Contraints:
The number of individual feedback responses might differ from the total number of people who participated in the session. Use the provided total number of respondents to calculate the average score.

If the input feedback string is empty, the sentiment scores should be 0 and the key findings should be an empty string.

please let me know if you have questions.

= = = 


= = = = 

now that i have the gemini api installed in my flutter project, here is how i want to use it:
some questions in my templates are open-ended like answers submitted by users in lib/components/molecules/text_field_card.dart. these are used for capturing feedback from users.
 
the gemini api will analyse the feedback from all users who submitted feedback for a single session to perform a sentiment analysis on the text.
the ai should analyze the text and return with:
1. sentiment_score: an integer value between 0 and 100, where 0 is the most negative and 100 is the most positive.
2. then take a total score given by all submitted open ended feedback divided by number of people who answered the open ended question (through a text field) Take note that not every user will submit a free text feedback. This means the number of people who answer that question maybe different to the number of people who submitted the entire template  that consists of other questions in that session.
2. key_findings: a concise, comma-separated list of keywords and short phrases summarizing the main points.
the purpose is to make the results meaningful for improving my facilitation skills based on user feedback.
a card called lib/components/molecules/sentiment_answers_card.dart will be used to populate the results


Giphy API