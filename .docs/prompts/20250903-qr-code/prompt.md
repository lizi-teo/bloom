using #ff can you fix  a molecule called lib/components/molecules/button_card.dart. the link is **button card** in #fl, please extract css styling from this figma link and identify matching style from flutter theme, then apply only flutter theme. Your task is to fix the styling of the tonal button and the spacing between elements. Check against slider_cart.dart and text_field_cart.dart for standardised styling. Ensure you use ONLY surface container style from flutter theme for the card's container colour. When the user selected an answer, the button should remain in a clicked state to show its been selected.



using #ff create a molecule called session_list_card. the link is **session list card** in #fl, please extract css styling from this figma link and identify matching style from flutter theme, then apply only flutter theme. This component is a varied style of "stacked" card from material esign 3, you may use the building block that came from this component. ensure you use ONLY surface container style from flutter theme for the card's container colour.

using #ff create a molecule called session_qr_code_card. the link is **session qr code card** in #fl, please extract css styling from this figma link and identify matching style from flutter theme, then apply only flutter theme. This component is a varied style of "stacked" card from material esign 3, you may use the building block that came from this component. ensure you use ONLY surface container style from flutter theme for the card's container colour. check lib/components/molecules/results_answers_card.dart for styling standards.


using #ff create a page called dyanmic_qr_code_page in template folder. the link is **QR code page** in #fl, please extract css styling from this figma link and identify matching style from flutter theme, then apply only flutter theme. This page is made of molecules in the existing molecules folder:
lib/components/molecules/results_header.dart
lib/components/molecules/session_qr_code_card.dart
lib/components/molecules/decoration_tape.dart
Please use only these existing components. 
ensure you use ONLY surface container style from flutter theme for the card's container colour. check lib/features/sessions/templates/dynamic_template_page.dart for styling standards.


For dynamic_qr_code_page:
As a facilitator I want to generate the qr code page with the participants.
From a card in lib/features/sessions/screens/sessions_list_screen.dart, i want to click on the optional button that goes to the lib/features/sessions/templates/dynamic_qr_code_page.dart. Perhaps this button can say only "Share"
The button on trigger would create a migration to add the  session_code and participant_access_url to the session table in supabase.
This dynamic_qr_code_page then shows a generated qr code and shareable link.

