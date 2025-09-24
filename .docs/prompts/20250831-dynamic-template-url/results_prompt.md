#fl create a decoration tape in molecules folder. use #ff as instructions.
this decoration tape  contains image_url retrieved from the section id.
each section id contains a template that comes with a image url.
the system should retrive the image url from the database based on the section id.
can you have the background of this tape pick up a colour from the background colour of each image_url. please test that this works for different image url
ask me if you have questions


= = = = 
Context: i am working on a flutter application and need to display a results page for a dynamic session.

Task: i need you to help me with the code for the results page header.

Instructions:

#fl create a header for results molecule in molecules folder. use #ff as instructions.

The header needs to be populated with data from a database.

Use the template_id and results_answers tables to retrieve the necessary information.

Calculate the number of submissions for each section ID.

Display the number of submissions in the section header, replacing "00 submitted" with the calculated number.

There is a circle with a numeric value for tertiary styling. this circle should display a number that is the average of all results for a given template, divided by the total number of participants who submitted that session id's dynamic template.

The code should be dynamic and work for any session, template, and component combination.

= = = = = 

Improved prompt for creating a results card
Here is a more detailed and effective prompt based on your request. This version provides a clearer structure, specific constraints, and a defined output format, which should lead to a more accurate result.

#ff instructions

Create a data visualization component named results_answers_card within the molecules folder. The component must display user-selected results from a specific sectionID.

## User requirements

Purpose: to display results that a user has selected.

Input: the card will receive a sectionID as input, which corresponds to a specific set of user answers.

Data retrieval: fetch all relevant data by querying the database using the provided sectionID.

Tables to use:

results_answers table: contains the user's answers.

questions table: contains the full text of each question.

templates table: contains the display templates for each question type.

Card content: the card should display each question and its corresponding answer.

Formatting: each row should include the question text followed by a circular visual element containing a numeric value.

Data mapping: the number inside the circle must correspond to the numeric value from the results_answers table for that specific question.

Output: the final component should be a card molecule that is ready for integration into a larger application.