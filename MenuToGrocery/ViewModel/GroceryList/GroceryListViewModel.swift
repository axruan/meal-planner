//
//  GroceryListViewModel.swift
//
//
///This class is the view model for grocery list screen. It bridges the view and network layer to retrieve data from Firestore.
///It uses Combine to asynchronously get data from Firestore then asseble a usable grocery list consumed by the view
///
import Foundation
import Combine

class GroceryListViewModel: ObservableObject {
    @Published var groceryListRepository = FirebaseRepository()
    @Published var groceryList = [GroceryCategoryViewModel]()
    static let shared = GroceryListViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    //Initialier
    //It gets response from Firestore, then use the data to assemble a groceryList
    private init() {
        groceryListRepository.$groceryList.map { groceryList in
            groceryList.map(GroceryCategoryViewModel.init)
        }
        .assign(to: \.groceryList, on: self)
        .store(in: &cancellables)
    }
    
    //Check if the grocery item from same recipe is already in the grocery list
    func has(_ groceryItem: GroceryItem) -> Bool {
        for category in groceryList {
            if category.groceryCategory.groceryItems.contains(where: {$0 == groceryItem}) {
                return true
            }
        }
        return false
    }

    //Add a grocery item to grocery list
    func add(_ grocery: GroceryItem) {
        if has(grocery) {return}
        
        for index in 0..<groceryList.count {
            if groceryList[index].groceryCategory.name == grocery.category {
                groceryList[index].groceryCategory.groceryItems.append(grocery)
                groceryListRepository.updateGroceryListWith(groceryList[index].groceryCategory)
                return
            }
        }
        groceryListRepository.add(GroceryCategory(name: grocery.category, groceryItems: [grocery]))
    }

    //Add a recipe's ingredients to grocery list
    func add(_ recipe: Recipe){
        //generate grocelistItem list from recipe
        let groceryItems = recipe.ingredients.compactMap { GroceryItem(category: $0.foodCategory ?? "Optional", name: $0.food, quantity: $0.quantity, measure: $0.measure, recipe: recipe)}
        
        for item in groceryItems {
            add(item)
        }
    }

    //Remove a single grocery item from grocery list
    func remove(_ grocery: GroceryItem) {
        for index in 0..<groceryList.count {
            if groceryList[index].groceryCategory.name == grocery.category {
                groceryList[index].groceryCategory.groceryItems.removeAll(where: {$0 == grocery})
                if groceryList[index].groceryCategory.groceryItems.count == 0 {
                    groceryListRepository.removeGroceryCategory(groceryList[index].groceryCategory)
                } else {
                    groceryListRepository.updateGroceryListWith(groceryList[index].groceryCategory)
                }
                return
            }
        }
    }
    
    //Remove a recipe's ingredients from grocery list
    func remove(_ recipe:Recipe) {
        let groceryItems = recipe.ingredients.compactMap { GroceryItem(category: $0.foodCategory ?? "Optional", name: $0.food, quantity: $0.quantity, measure: $0.measure, recipe: recipe)}
        
        for item in groceryItems {
            remove(item)
        }
    }
    
    //Empty grocery list
    func emptyGroceryList() {
        groceryListRepository.emptyGroceryList()
    }
    
    
    //rearrange grocery list
    //If a food category has 0 recipe, then remove the category.  Otherwise sort recipes by name
    //In the last sort groceryList by food category
    func sortAndClean() {
        groceryListRepository.sortAndCleanGroceryList()
    }

    //Toggle a grocery item's status between bought and not-bought
    func toggle(_ grocery: GroceryItem) {
        if !has(grocery) {return }
        
        let selectedCategoryVM = groceryList.filter{$0.groceryCategory.name == grocery.category}
        
        let selectedGrocertyItem = selectedCategoryVM[0].groceryCategory.groceryItems.filter{$0 == grocery}
        
        groceryListRepository.toggleGroceryItem(item:selectedGrocertyItem[0], category: selectedCategoryVM[0].groceryCategory)
        
    }
    
    //Force any view that uses this class as an ObervedObject to refresh
    func refresh() {
        groceryListRepository.updateView()
    }
    
    //Check if toggle an item is made to the Firestore
    func isToggleReady() -> Bool{
        return groceryListRepository.toggleIsReady
    }
}
