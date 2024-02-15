//
//  MealPlanViewModel.swift
//
//
///This class is the view model for meal plan screen. It bridges meal plan screen and the network layer to get meal plan from Firestore.
///It uses Combine to asynchronously get data from Firestore then asseble a usable list of meal plan consumed by the view
///
import Foundation
import Combine

class MealPlanViewModel: ObservableObject {
    @Published var mealRepository = FirebaseRepository()
    @Published var mealPlan = [RecipeViewModel]()
    static let shared = MealPlanViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    private init() {
        mealRepository.$mealPlan.map { recipes in
          recipes.map(RecipeViewModel.init)
        }
        .assign(to: \.mealPlan, on: self)
        .store(in: &cancellables)
    }
        
    func add(_ recipe: Recipe?) {
        guard let recipe =  recipe else {return}

        //mealRepository.add(recipe)
        mealRepository.addRecipe(recipe)
    }
    
    ///Check if a cuisine is in the meal plan, if it's true, then return the recipe list that belong to the cuisine type
    ///In paremeter : `cuisine` -- the cuisine type to be checked
    ///Return: `RecipeByCuisineType` -- optional.  Only if the cuisine is in the meal plan, return a list of recipes, otherwise return nil
    ///TODO; 
    func has(_  recipe:  Recipe) -> Bool {
        let recipes = mealPlan.compactMap{$0.recipe}
        return recipes.contains(recipe)
    }

    func remove (_ recipe: Recipe) {
        let recipes = mealPlan.compactMap{$0.recipe}
        if let existingRecipe = recipes.first(where: {$0 == recipe}) {
            mealRepository.removeRecipe(existingRecipe)
        }
    }
    
    func emptyRecipe() {
        mealRepository.emptyMealPlan()
    }
    
    func getRecipesForAdvice() -> String {
        
        var recipeNames = ""
        for meal in mealPlan {
            recipeNames.append(meal.recipe.label)
            recipeNames.append(",")
        }
       
        if !recipeNames.isEmpty {
            recipeNames = String(recipeNames.dropLast(1))
        }
        
        return recipeNames
    }
    
    func readyForAdvice() -> Bool {
        if getRecipesForAdvice() == "" {
            return false
        } else {
            return true
        }
    }
}
