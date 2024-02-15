Mean planner

This app uses Edamam Recipe API to get recipes based on search criteria.
Users can add recipes to their meal plan or favorites.
Everytime a recipe is added to/deleted from a meal plan, its corresponding ingredients are added to/removed from grocery list. 
The meal plan, favorite recipes, and grocery list are persisted in Firestore so that next time user comes back, previously saved data is retrieved.
The aforementioned lists can alos be emptied. By emptying the meal plan, the grocery list is emptied too.  This is a one directional impact. Emptying favorite recipes or grocery list does not impact other lists.
After the user selects at least one recipe to the meal plan, users can consult with chatGPT to comment on the meal plan.

#Search screen#

The search screen allows users to search for recipes from the Edamam Recipe Database. They can search with or without the cuisine and meal type filter. If the search is non-empty, a list of recipes come back. The recipes can be added to and removed from the meal plan and favorite recipes.

A recipe can be expanded by clicking on a recipe, that leads to Single recipe screen.


<img src='https://github.com/axruan/MenuToGrocery/assets/109245867/664bd7f4-ae22-46f2-aa4d-e1186c1091cd' width='150'>
<img src='https://github.com/axruan/MenuToGrocery/assets/109245867/e1c95fea-eeff-4c22-9f4e-1e0a8fde8c18' width='150'>


#Meal plan screen#

The meal plan screen holds the recipes users add to their meal plan. They are not categorized and ordered by recently added; users can remove the recipe once they are done. Individual recipes can be clicked on and viewed. The ChatGPT Advice button sits to the left of the title.
When a recipe is added to the meal plan, its ingredients are automatically added to the grocery list. When a recipe is removed, its ingredients are also removed from the grocery list.

<img src='https://github.com/axruan/MenuToGrocery/assets/109245867/0bdece02-ea14-4d66-bb86-8a4aa78edc83' width='150'>


#Favorite recipe screen#

The favorite recipes screen holds the recipes users like the most. It is sorted by cuisine type and can be emptied. The favorites screen do not affect the meal plan or the grocery list. Individual recipes can be clicked on and viewed.

<img src='https://github.com/axruan/MenuToGrocery/assets/109245867/e8dbf30f-8eff-4281-971b-f3b86e4020d8' width='150'>

#Grocery list screen#
The grocery list screen are all the ingredients from the user's meal plan that is automatically loaded. The list is sorted by type and can be checked off. Users can press on an ingredient to see what recipe it belongs to.

<img src='https://github.com/axruan/MenuToGrocery/assets/109245867/46895c15-4813-41fc-9114-b2e28874f5f9' width='150'>
     
#Single recipe screen#

The single recipe screen contains a picture of the dish, cuisine, calories, prep time, and ingredients. At the top, users can add the recipe to their meal plan or their favorites. The instructions button at the bottom leads users to an external link. 

<img src='https://github.com/axruan/MenuToGrocery/assets/109245867/873aec6a-e191-4487-934d-77f7f4104ec1' width='150'>

#ChatGPT advice half-sheet#

This half-sheet can be accessed from the meal plan screen by pressing on the sticky. Users can input their sex and age, then click on the button to receive information about their meal based on their information by ChatGPT. Advice will only be generated if at least one recipe is in the meal plan. 

<img src='https://github.com/axruan/MenuToGrocery/assets/109245867/71b8c3cf-9aa7-4230-9968-f54ce52a0057' width='150'>
<img src='https://github.com/axruan/MenuToGrocery/assets/109245867/cae3e947-1d64-4438-9685-a430a67b6946' width='150'>
<img src='https://github.com/axruan/MenuToGrocery/assets/109245867/67bfa6f4-d78f-4675-b70d-85faf9ce0325' width='150'>

