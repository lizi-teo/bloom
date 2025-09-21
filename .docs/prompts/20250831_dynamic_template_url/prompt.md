Steps for telling a story:
Tell it what i want overall
tell the story of backend information
then
tell the story of front end information

can you update lib/molecules/button_card.dart by referencing the figma link in #fl. use #ff examples of styling can be seen in lib/molecules/button_card.dart  

= = = = = 
I want this header to appear in a results page 
The system should get the information it needs from the database using the template id and results_answers table
The system should calculate the number of results submitted for each section ID and show this in the section that says "00 submitted", i want to know how many users submitted a section id dynamic page.
for  the tertiary styling circle that displays numeric, the system should get and display a number derive by  averaging  all results in a template divided by number of submissions, which are the number of participants who submitted the dynamic template of a sessions ID.
do you have auqestions for me

= = = = = 
I want the system to load a template dynamically.

The system should get the information it needs from the database using the session_id.

The related tables are session table, a template table, questions table, results table, and results_answers table.

= = = = = 

Please help me update the lib/features/sessions/templates/dynamic_template_page.dart file. I need it to dynamically load a session and its associated template, which has various questions and components. The components should be retrieved from the 'molecules' folder. The session ID page will be provided to the user, and their answers will be stored in the results_answers table in the database.

Additional context
Current functionality: The current code works, but only for static sessions and templates.
Goal: The goal is to make the system scalable so it can handle any session or template dynamically without requiring code changes.
Database tables: You have a session table, a template table, questions table, results table, and results_answers table. The session and template tables are linked, and the questions are linked to associated component type in the questions table. 

The outcome of the url that the user see should be something like /session/1 and the system will load the dynamic template page based on session ID = 1 for example

tell me if you have questions


Your primary goal is to fetch session data, its associated template, and all related components from a database. Then, based on the component type, you must dynamically instantiate a Dart widget.

    -   Assume the molecules (e.g., `slider_card`, `text_field_card`) exist in the `molecules` directory.
    -   updated code for the `session-template-get.dart` file.
    -   Include comments to explain each major step in the code.

