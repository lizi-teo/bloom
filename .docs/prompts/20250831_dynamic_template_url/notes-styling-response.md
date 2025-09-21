 for /Users/lizzieteo/Development/bloom-app/lib/molecules/results_answers_card.dart the title of the 
  questions from the questions table are missing from the database. can you also recheck the styling 
  using #fig from #fl. apply styling rules based on example text_field_card.dart

⏺ I'll help you fix the missing question titles in the results_answers_card.dart and update the styling
   using Figma. Let me start by examining the current file and then use the Figma integration.

⏺ Read(lib/molecules/results_answers_card.dart)
  ⎿  Read 179 lines (ctrl+r to expand)

⏺ I can see the issue! The database query on line 35 is selecting questions(question_id, question, 
  component_type_id) but trying to access item['questions']['question'] on line 132. The field should
  be title instead of question. Let me check the Figma links first:

⏺ Read(.docs/figma-links.md)
  ⎿  Read 50 lines (ctrl+r to expand)

⏺ Now let me use the Figma MCP server to analyze the results answers component styling:

⏺ figma-dev-mode-mcp-server - get_variable_defs (MCP)(nodeId: "60135-4346", clientFrameworks: "flutter",
                                                     clientLanguages: "dart")
  ⎿  {                                                                                                
       "Schemes/On Surface": "#1d1b20",
       "Static/Headline Small/Tracking": "0",
     … +24 lines (ctrl+r to expand)

⏺ figma-dev-mode-mcp-server - get_code (MCP)(nodeId: "60135-4346", clientFrameworks: "flutter",
                                            clientLanguages: "dart")
  ⎿  const imgDivider = "http://localhost:3845/assets/e816d159ae7032e5ee3a7ee78c450c9c60d031f9.svg";  

     function HorizontalFullWidth() {
     … +126 lines (ctrl+r to expand)
  ⎿ Use tailwind if available, otherwise detect the project's styling approach (e.g. CSS in JS, CSS Mo
    dules, theme providers, etc) and follow it. Use vanilla CSS only if no system is detected. Do not
    install any dependencies.

  ⎿  Node ids have been added to the code as data attributes, e.g. `data-node-id="1:2"`.
  ⎿ These variables are contained in the design: Schemes/On Surface: #1d1b20, Static/Headline Small/Tr
    acking: 0, Static/Headline Medium/Size: 28, Static/Headline Medium/Weight: Regular, Static/Headlin
    e Medium/Font: Questrial, Static/Headline Medium/Line Height: 36, M3/sys/light/on-surface: #1D1B20
    … +7 lines (ctrl+r to expand)



  ⎿ Image assets are stored on a localhost server. Clients can use these images directly in code as a
    way to view the image assets the same way they would other remote servers. Images and SVGs will be
     stored as constants, e.g. const image = 'http://localhost:3845/assets/10c13ac1a228a365cb98a0064b1
    … +3 lines (ctrl+r to expand)


  ⎿ IMPORTANT: After you call this tool, you MUST call get_image to get an image of the node for conte
    xt.


⏺ figma-dev-mode-mcp-server - get_image (MCP)(nodeId: "60135-4346", clientFrameworks: "flutter",
                                             clientLanguages: "dart")
  ⎿  [Image]                                                                                          

⏺ Now let me check the text_field_card.dart for styling reference:

⏺ Read(lib/molecules/text_field_card.dart)
  ⎿  Read 209 lines (ctrl+r to expand)

⏺ Now I can see the issues and fix them. Looking at the database query and Figma analysis:

  1. Database Issue: The query selects question field but should select title field from the questions
  table
  2. Styling Issues: Based on the Figma design, I need to update the styling to match exactly:
    - Use Questrial font for the question title (28px, line height 36)
    - Use Roboto for the question description (14px, line height 20)
    - Each question should have a title and subtitle layout like the Figma design
    - The circle should be 60px (not 48px) with proper background colors
    - Add proper spacing and dividers between items