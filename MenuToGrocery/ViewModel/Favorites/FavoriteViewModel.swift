//
//  FavoriteViewModel.swift
//
//
//////This class is the view model for favorite recipes screen. It bridges favorite recipes screen and the network layer to get favorite recipes  from Firestore.
///It uses Combine to asynchronously get data from Firestore then asseble a usable list of favorite recipes consumed by the view
///
import Foundation
import Combine

class FavoriteViewModel: ObservableObject {
    @Published var favoritesRepository = FirebaseRepository()
    @Published var favorites = [RecipeByCuisineTypeViewModel]()
    static let shared = FavoriteViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    private init() {
        favoritesRepository.$favorites.map { favorites in
            favorites.map(RecipeByCuisineTypeViewModel.init)
        }
        .assign(to: \.favorites, on: self)
        .store(in: &cancellables)
    }
    
    func add(_ recipe: Recipe?) {
        guard let recipe =  recipe else {return}
        
        for i in 0..<favorites.count {
            if  recipe.mainCuisineType == favorites[i].recipeByCuisineType.cuisineType {
                // add recipe to recipeByCuisine.recipes
                favorites[i].recipeByCuisineType.recipes.append(recipe)
                favoritesRepository.updateFavoritesWith(favorites[i].recipeByCuisineType)
                return
            }
        }
        
        //favorites.append(RecipeByCuisineType(cuisineType: recipe.mainCuisineType , recipes: [recipe]))
        favoritesRepository.add(RecipeByCuisineType(cuisineType: recipe.mainCuisineType , recipes: [recipe]))
    }
    
    
    ///Check if a cuisine is in favorite meals, if it's true, then return the recipe list that belong to the cuisine type
    ///In paremeter : `cuisine` -- the cuisine type to be checked
    ///Return: `RecipeByCuisineType` -- optional.  Only if the cuisine is in the favorite meals, return a list of recipes, otherwise return nil
    func hasCuisine(_ type: String) -> RecipeByCuisineType? {
        let favoriteCuisineTypes = favorites.compactMap({$0.recipeByCuisineType})
        return favoriteCuisineTypes.first(where: {$0.cuisineType == type})
    }
    
    func has(_ recipe: Recipe) -> Bool {
        guard let recipeByCuisineType = hasCuisine(recipe.mainCuisineType) else {
            return false
        }
        
        if recipeByCuisineType.has(recipe) {
            return true
        } else {
            return false
        }
    }
    
    
    func remove (_ recipe: Recipe) {
        for i in 0..<favorites.count {
            if  recipe.mainCuisineType == favorites[i].recipeByCuisineType.cuisineType {
                // remove recipe from recipeByCuisine.recipes
                favorites[i].recipeByCuisineType.recipes.removeAll(where : {$0 == recipe})
                if favorites[i].recipeByCuisineType.recipes.count == 0 {
                    favoritesRepository.removeCuisineFromFavorites(favorites[i].recipeByCuisineType)
                } else {
                    favoritesRepository.updateFavoritesWith(favorites[i].recipeByCuisineType)
                }
                return
            }
        }
        
    }
    
    func emptyFavorites() {
        favoritesRepository.emptyFavorites()
    }
}
