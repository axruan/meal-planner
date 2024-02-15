//
//  SearchView.swift
//
//
///This view allows user to search for recipes.
///It's has a keyword search text ,  search button, two search criterias.
///User has to click "Search" button to see recipes.
///By default, the 2 search search criteira has no selection.  In this condition, the recipe contains all cuisine types and all meal types.
///If user wants to narrow down result, select a choice from Cuisine type and/or meal type.
///If no result is returned, a message is displayed to notify user there is no search result.
///If non-empty recipe result comes back, the view shows a list of recipes.
///
import SwiftUI

struct SearchView: View {
    @ObservedObject var searchViewModel = SearchViewModel.shared
    @State var recipeSearchPhrase = ""
    @State var selectedCuisineType = "empty"
    let cuisineOptions = ["empty", "American", "Asian", "British"]
    @State var selectedMealType = "empty"
    let mealOptions = ["empty", "Dinner", "Lunch", "Breakfast","Snack"]
    @State var selectedRecipe : Recipe? = nil
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                TextField("Enter recipe name", text: $recipeSearchPhrase)
                    .padding(.leading, 5)
                
                Button(action: {
                    searchViewModel.getRecipe(search: recipeSearchPhrase,
                                              cuisineType: selectedCuisineType,
                                              mealType: selectedMealType)
                },
                       label: {
                    Text("Search")
                        .bold()
                })
                .padding(.trailing, 30)
                .disabled(recipeSearchPhrase == "")
            }
            .padding(.top, 10)
            .padding(.bottom,10)
            .border(.blue)
            .padding(30)
            
            HStack {
                Text("Cuisine Type:")
                    .padding(.leading, 40)
                Spacer()
                
                Picker("Cuisine Type", selection: $selectedCuisineType) {
                    ForEach(cuisineOptions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 200)
            }
            
            
            HStack {
                Text("Meal Type:")
                    .padding(.leading, 40)
                Spacer()
                
                Picker("Meal Type", selection: $selectedMealType) {
                    ForEach(mealOptions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 200)
            }
            
            //Spacer()
            
            if searchViewModel.recipes.count > 0 {
                List{
                    ForEach(searchViewModel.recipes) { recipe in
                        smallRecipeView(recipe: recipe, selectedRecipe: $selectedRecipe)
                    }
                }
            }else {if searchViewModel.searched {
                Text("No recipe is found with your search")
                //.bold()
                    .font(.system(size:20, weight: .heavy, design: .rounded))
                    .foregroundColor(.red)
                    .padding(.top, 20)
                //.border(.pink, width:5)
            }
            }
            
            Spacer()
            Spacer()
        }
        .sheet(item: $selectedRecipe) { item in     // activated on selected item
            RecipeView(recipe: item)   //TODO: !
                .presentationDetents([.large])
        }
    }
}

///This view displays a single recipe for search screen
///The view shows a small image of the recipe, recipe name, cuisine type and total calories
///At the right side of the view, it has 2 buttons that allows the recipe to be added to the mealPlan and favorite list.
///The view is tappable, once tapped, it leads to the detailed recipe view
///
struct smallRecipeView: View {
    let recipe : Recipe
    @Binding var selectedRecipe: Recipe?
    
    var body: some View {
        
        HStack {
            HStack {
                AsyncImage(
                    url: URL(string: "\(recipe.image)"),
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 100, maxHeight: 100)
                    },
                    placeholder: {
                        Text("Loading...")
                            .frame(maxWidth: 100, maxHeight: 100)
                    }
                )
                .padding()
                
                Spacer()
                VStack {
                    Text("\(recipe.label)")
                        .bold()
                    Text("Cuisine: \(recipe.mainCuisineType)") //TODO: check if this optional field
                    Text("Calories: \(Int(recipe.calories))")
                    
                }
                Spacer()
            }
            .onTapGesture {
                selectedRecipe = recipe
            }
            
            VStack {
                AddToMealPlanAndFavoriteButtons(recipe: recipe)
            }
            .padding(.trailing, 10)
        }
        .frame(width: UIScreen.screenWidth - 20)
        .border(.gray, width: 5)
    }
}

///This view has 2 buttons only, one for mealPlan, the other favorite list.
///If the button is not clicked, it's green.  Once clicked the red color indicates the recipe is added to the corresponding list.
///
///The view can be seen in search view, recipe view.  In search view, for each recipe,
///the 2 buttons are displayed vertically; in recipe view, the buttons are displayed horizontally.
///
///To single out this view not only to reduce redundacy of code between search view and recipe view
///it also helps to centralize the location where mealplan and grocery list are updated
///
struct AddToMealPlanAndFavoriteButtons: View {
    @ObservedObject var mealViewModel = MealPlanViewModel.shared
    @ObservedObject var favoriteViewModel = FavoriteViewModel.shared
    @ObservedObject var groceryListViewModel = GroceryListViewModel.shared
    var recipe: Recipe
    
    var body: some View {
        //add to meal plan button
        Button(action: {
            if mealViewModel.has(recipe) {
                mealViewModel.remove(recipe)
            } else {
                mealViewModel.add(recipe)
            }
        }, label: {
            Image(mealViewModel.has(recipe) ? "mealPlan_red" : "mealPlan_green")
                .resizable()
                .frame(width:roundCircleButtonWidth, height: roundCircleButtonWidth)
                .clipShape(Circle())
            
        })
        .buttonStyle(.borderless)
        .padding(1)
        .clipShape(Circle())
        
        //add to favorite button
        Button(action: {
            if favoriteViewModel.has(recipe) {
                favoriteViewModel.remove(recipe)
            } else {
                favoriteViewModel.add(recipe)
                
            }
        }, label: {
            Image(systemName: favoriteViewModel.has(recipe) ? "heart.fill" : "heart")
                .resizable()
                .foregroundColor(favoriteViewModel.has(recipe) ? .red : .green)
                .frame(width: roundCircleButtonWidth - 6, height: roundCircleButtonWidth - 6)
        })
        .buttonStyle(.borderless)
        .padding(1)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
