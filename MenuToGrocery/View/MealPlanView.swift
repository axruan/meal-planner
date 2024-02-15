//
//  MealPlanView.swift
//
//
///This view shows user's meal plan.  it displays list of recipes selected from search screen.
///The recipe is not grouped by any category, it's shown in the order as they are added.
///
///By clicking on any recipe image, it leads to a detailed recipe screen.
///User can empty meal plan by clicking on top right trash can image.
///
///The view also allows user to consult ChatGPT on the selected meal plan by clicking on "Advice" image.   The chatgpt screen is showns as
///half sheet.
///
import SwiftUI
let recipeWidth = 120.0
let deleteSignWidth = 15.0

let layout = [
    GridItem(.flexible(minimum: 100)),
    GridItem(.flexible(minimum: 100)),
    GridItem(.flexible(minimum: 100))
]

struct MealPlanView: View {
    @ObservedObject var viewModel = MealPlanViewModel.shared
    @ObservedObject var groceryListViewModel = GroceryListViewModel.shared
    @State var emptyAlertPresented = false
    @State var isPresented = false
    
    var body: some View {
        NavigationView {
            VStack{
                HStack {
                    
                    Button {
                        isPresented.toggle()
                    } label: {
                        Image ("advice")
                            .resizable()
                            .frame(width: 60, height: 60)
                    }
                    .sheet(isPresented: $isPresented) {
                        AdviceView()
                            .presentationDetents([.medium])
                    }
                    
                    Text("Meal Plan")
                    //.font(.custom("AmericanTypewriter-Bold", fixedSize: 36))
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .padding()
                    
                    //empty meal plan button, it invokes an alert
                    Button(action: {
                        emptyAlertPresented.toggle()
                    }, label: {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width:25, height: 25)
                    })
                    .disabled(viewModel.mealPlan.count == 0)
                    .alert(isPresented: $emptyAlertPresented, content: {
                        Alert(title: Text("Both meal plan and grocery list are going to be deleted, are you sure of about it?"),
                              primaryButton: .default(Text("Yes"),action: {
                            viewModel.emptyRecipe()
                            groceryListViewModel.emptyGroceryList()
                        }),
                              secondaryButton: .cancel(Text("Cancel")))
                    })
                }
                RecipeGrid()
            }
        }
    }
}

///This view shows selected recipes in a grid.   Each recipe is shown as an image.
struct RecipeGrid:  View {
    @ObservedObject var viewModel = MealPlanViewModel.shared
    @State var selectedRecipe : Recipe? = nil
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: layout, content: {
                ForEach(viewModel.mealPlan, id: \.self) { recipeViewModel in
                    VStack {
                        Text("\(recipeViewModel.recipe.label)")
                            .font(.system(size: 12))
                            .frame(width: recipeWidth, height: 20)
                            .truncationMode(.tail)
                        RecipeSquareView(recipe:recipeViewModel.recipe)
                            .onTapGesture {
                                selectedRecipe = recipeViewModel.recipe
                            }
                    }
                    .sheet(item: $selectedRecipe) { item in     // activated on selected item
                        RecipeView(recipe: item)   //TODO: !
                            .presentationDetents([.large])
                    }
                }
            })
        }
    }
}

///This view shows a single recipe in meal plan screen, it's the smallest component of RecipeGrid.
///For each recipe, there is a "x" at the right top corner, by clicking it the recipe is deleted from the meal plan
///
struct RecipeSquareView: View {
    @ObservedObject var viewModel = MealPlanViewModel.shared
    let recipe: Recipe
    var body: some View {
        ZStack{
            AsyncImage(
                url: URL(string: "\(recipe.images.small.url)"),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: recipeWidth, maxHeight: recipeWidth)
                    
                },
                placeholder: {
                    Text("Loading...")
                        .frame(maxWidth: recipeWidth, maxHeight: recipeWidth)
                }
            )
            
            //delete sign
            VStack{
                HStack{
                    Spacer()
                    Button(action: {
                        viewModel.remove(recipe)
                    },
                           label: {
                        Image(systemName: "multiply")
                            .resizable()
                            .frame(width:deleteSignWidth, height:deleteSignWidth)
                            .foregroundColor(Color.white)
                        
                    })
                    .background(.blue.opacity(0.6))
                    .cornerRadius(40)
                    //.padding(.bottom, 10)
                    .shadow(color: Color.black.opacity(0.3),
                            radius: 3,
                            x: 3,
                            y: 3)
                }
                Spacer()
            }
            .frame(width: recipeWidth, height: recipeWidth)
        }
    }
}

struct MealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        MealPlanView()
    }
}
