//
// FirebaseRepository.swift
//
//
///This class is responsible to get,update and delete meal plan, favorite recipes and grocery list from FireStore
///It uses Combine to acomplish async operations.
///
///I learned how to use Firestore through this wonderful tutorial: https://www.kodeco.com/11609977-getting-started-with-cloud-firestore-and-swiftui#toc-anchor-002
///
///There are 3 types of documents saved in firestore: meal plan, favorite recipes and grocery list
///When a recipe is added to/deleted  from a meal plan, its ingredients are automatically translated and added to/deleted from the  grocery list.
///If the meal plan is emptied, grocery list is emptied too. The opposite is not true.   So it's a one way direction from meal plan to grocery list.
///By adding a recipe to favorite recipes does not impact grocery list or meal plan.
///
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class FirebaseRepository: ObservableObject {
    @Published var loading = false
    private let mealPlanPath: String = "mealPlan"
    private let favoritesPath: String = "favorites"
    private let groceryListPath: String = "groceryList"
    private let store = Firestore.firestore()
    
    @Published var mealPlan = [Recipe]()
    @Published var favorites = [RecipeByCuisineType]()
    @Published var groceryList = [GroceryCategory]()
    
    var userId = ""
    private let authenticationService = AuthenticationService()
    private var cancellables: Set<AnyCancellable> = []
    @Published var toggleIsReady = true
    
    ///initializer
    init() {
        authenticationService.$user
            .compactMap { user in
                user?.uid
            }
            .assign(to: \.userId, on: self)
            .store(in: &cancellables)
        
        authenticationService.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.getMealPlan()
                self?.getFavorites()
                self?.getGroceryList()
            }
            .store(in: &cancellables)
    }
    
    //MARK: meal plan operations
    
    ///This function get entire meal plan's recipes from Firestore by adding a snapshot listener to the root of meal plan collection.
    ///Whenever the meal plan is changed in Firestore, it will be automatically retrieved by this function.
    func getMealPlan() {
        store.collection(mealPlanPath)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting cards: \(error.localizedDescription)")
                    return
                }
                
                self.mealPlan = querySnapshot?.documents.compactMap { document in
                    var recipe : Recipe? = try? document.data(as: Recipe.self)
                    recipe?.id = document.documentID
                    return recipe
                } ?? []
            }
    }
    
    ///Delete all documents of meal plan  in Firestore
    func emptyMealPlan(){
        let batch = store.batch()
        for recipe in mealPlan{
            guard let recipeId = recipe.id else { return }
            let document = store.collection(mealPlanPath).document(recipeId)
            batch.deleteDocument(document)
        }
        batch.commit(){ err in
            if let err = err {
                print("Error emptying meal plan- \(err)")
            } else {
                print("Batch operation for emptying meal plan succeeded.")
            }
        }
    }
    
    ///Update one recipe in the meal plan
    ///In parameter `recipe` -- the recipe to be updated
    func updateMealPlanWith(_ recipe: Recipe) {
        guard let recipeId = recipe.id else { return }
        
        do {
            try store.collection(mealPlanPath).document(recipeId).setData(from: recipe)
        } catch {
            fatalError("Unable to update \(recipe.label) in Mealplan: \(error.localizedDescription).")
        }
    }
    
    ///Add a recipe to mealplan
    ///In paramert `recipe` -- the recipe to be added
    func add(_ recipe: Recipe) {
        do {
            _ = try store.collection(mealPlanPath).addDocument(from:recipe )
        } catch {
            fatalError("Unable to add \(recipe.label) to Mealplan: \(error.localizedDescription).")
        }
    }
    
    //MARK: favorite recipes operations
    
    ///This function get favorite recipes from Firestore by adding a snapshot listener to the root of favorite recipe collection.
    ///Whenever the favorite recipies  are changed in Firestore, the list will be automatically retrieved by this function.
    func getFavorites() {
        store.collection(favoritesPath)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting cards: \(error.localizedDescription)")
                    return
                }
                
                self.favorites = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: RecipeByCuisineType.self)
                } ?? []
            }
    }
    
    ///Add a RecipeByCuisineType to favorite recipe list
    ///In parameter `recipeByCuisine`:RecipeByCuisineType -- the cuisine type to be added to the favorite recipe list
    func add(_ recipeByCuisine: RecipeByCuisineType) {
        do {
            _ = try store.collection(favoritesPath).addDocument(from: recipeByCuisine)
        } catch {
            fatalError("Unable to add \(recipeByCuisine.cuisineType) to Faborites: \(error.localizedDescription).")
        }
    }
    
    ///Update and existing cuisine type within the favorite recipe list
    ///In parameter `recipeByCuisine`: RecipeByCuisineType -- the cuisine type to be udpated
    func updateFavoritesWith(_ recipeByCuisine: RecipeByCuisineType) {
        guard let recipeByCuisineId = recipeByCuisine.id else { return }
        
        do {
            try store.collection(favoritesPath).document(recipeByCuisineId).setData(from: recipeByCuisine)
        } catch {
            fatalError("Unable to update \(recipeByCuisine.cuisineType) in Favorites: \(error.localizedDescription).")
        }
    }
    
    ///Remove a cuisine type from favorite recipe list
    ///In parameter `recipeByCuisine`:RecipeByCuisineType -- the cuisine type to be removed from favorite recipe list
    func removeCuisineFromFavorites(_ recipeByCuisine: RecipeByCuisineType){
        guard let recipeByCuisineId = recipeByCuisine.id else { return }
        
        store.collection(favoritesPath).document(recipeByCuisineId).delete { error in
            if let error = error {
                print("Unable to remove \(recipeByCuisine.cuisineType) from Favorites: \(error.localizedDescription)")
            }
        }
    }
    
    ///Empty favorite recipe list
    func emptyFavorites(){
        let batch = store.batch()
        for favoriteCuisine in favorites{
            guard let recipeByCuisineId = favoriteCuisine.id else { return }
            
            let document = store.collection(favoritesPath).document(recipeByCuisineId)
            batch.deleteDocument(document)
        }
        batch.commit() { err in
            if let err = err {
                print("Error emptying favorites - \(err)")
            } else {
                print("Batch operation for emptying favorites succeeded.")
            }
        }
    }
    
    //MARK: grocery list operations
    
    ///This function get grocery list from Firestore by adding a snapshot listener to the root of grocery list collection.
    ///Whenever the grocery list  is changed in Firestore, the list will be automatically retrieved by this function.
    func getGroceryList() {
        store.collection(groceryListPath)
        //.whereField("userId", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting cards: \(error.localizedDescription)")
                    return
                }
                
                self.groceryList = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: GroceryCategory.self)
                } ?? []
            }
    }
    
    ///Add GroceryCategory to grocery list
    ///In parameter: `groceryCategory`:GroceryCategory - new grocery category to be added to the grocery list
    func add(_ groceryCategory: GroceryCategory) {
        do {
            _ = try store.collection(groceryListPath).addDocument(from: groceryCategory)
        } catch {
            fatalError("Unable to add \(groceryCategory.name) to GroceryList: \(error.localizedDescription).")
        }
    }
    
    ///Update an existing grocery category within the grocery list
    ///In parameter `groceryCategory`: GroceryCategory - the new category to be added to the grocery list
    func updateGroceryListWith(_ groceryCategory: GroceryCategory) {
        guard let groceryCategoryId = groceryCategory.id else { return }
        
        do {
            try store.collection(groceryListPath).document(groceryCategoryId).setData(from: groceryCategory)
        } catch {
            fatalError("Unable to update \(groceryCategory.name) in Grocery list: \(error.localizedDescription).")
        }
    }
    
    ///Remove a grocery category from grocery list
    ///In parameter `groceryCategory`: GroceryCategory - the category to be removed from grocery list
    func removeGroceryCategory(_ groceryCategory: GroceryCategory) {
        guard let groceryCategoryId = groceryCategory.id else { return }
        
        store.collection(groceryListPath).document(groceryCategoryId).delete { error in
            if let error = error {
                print("Unable to remove \(groceryCategory.name) from Grocery list: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: combined operations, such as add recipe which also add its ingredients to grocery list
    
    ///Add a recipe to meal plan.  When a recipe is added  to meal plan, its ingredients are added to grocery list.
    ///In parameter: `recipe`:Recipe -- the recipe to be added
    ///
    func addRecipe(_ recipe: Recipe) {
        guard let _ = recipe.id else {return}
        
        //batch
        // Get new write batch
        let batch = store.batch()
        
        //add recipe to mealPlan
        let mealPlanRef = store.collection(mealPlanPath).document()
        do {
            try _ = batch.setData(from: recipe, forDocument: mealPlanRef)
        } catch {
            fatalError("Unable to add \(recipe.label) to Mealplan: \(error.localizedDescription).")
        }
        
        //translate recipe to groceryItems, then add it to a temporary grocery list
        let groceryItems = recipe.ingredients.compactMap { GroceryItem(category: $0.foodCategory ?? "Optinal", name: $0.food, quantity: $0.quantity, measure: $0.measure, recipe: recipe)}
        
        let groceryDictionary = Dictionary(grouping: groceryItems, by: { (element: GroceryItem) in
            return element.category
        })
        
        //let arr = myDict.map { "\($0.key) \($0.value)" }
        var newRecipeGroceryList = groceryDictionary.compactMap{GroceryCategory(name: "\($0.key)", groceryItems: $0.value)}
        
        //update/add category to repository's grocery list
        for index in 0..<newRecipeGroceryList.count{
            if let exisingCategory = groceryList.first(where: {$0.name == newRecipeGroceryList[index].name}) {
                
                //delete existing category
                let groceryRef = store.collection(groceryListPath).document(exisingCategory.id!)
                batch.deleteDocument(groceryRef)
                
                //merge grocery items in the same category
                newRecipeGroceryList[index].groceryItems = newRecipeGroceryList[index].groceryItems + exisingCategory.groceryItems
            }
            
            //add new category back to store
            let groceryRef = store.collection(groceryListPath).document()
            do {
                try _ = batch.setData(from: newRecipeGroceryList[index], forDocument: groceryRef)
            } catch {
                fatalError("Unable to add \(recipe.label) to Mealplan: \(error.localizedDescription).")
            }
        }
        
        // Commit the batch
        batch.commit() { err in
            if let err = err {
                print("Error adding recipe - \(err)")
            } else {
                print("Batch operation for adding recipe succeeded.")
            }
        }
    }
    
    ///Remove a recipe from meal plan.  When a recipe is removed  from meal plan, its ingredients are removed from grocery list.
    ///In parameter: `recipe`:Recipe -- the recipe to be removed
    ///
    func removeRecipe(_ recipe: Recipe) {
        guard let recipeId = recipe.id else {return}
        
        //batch
        // Get new write batch
        let batch = store.batch()
        
        //delete recipe from mealPlan
        let recipeRef = store.collection(mealPlanPath).document(recipeId)
        batch.deleteDocument(recipeRef)
        
        //translate recipe to groceryItems, then add it to a temporary grocery list
        let groceryItems = recipe.ingredients.compactMap { GroceryItem(category: $0.foodCategory ?? "Optional", name: $0.food, quantity: $0.quantity, measure: $0.measure, recipe: recipe)}
        
        let groceryDictionary = Dictionary(grouping: groceryItems, by: { (element: GroceryItem) in
            return element.category
        })

        var newRecipeGroceryList = groceryDictionary.compactMap{GroceryCategory(name: "\($0.key)", groceryItems: $0.value)}
        
        //update/remove category to repository's grocery list
        for index in 0..<newRecipeGroceryList.count{
            if var exisingCategory = groceryList.first(where: {$0.name == newRecipeGroceryList[index].name}) {
                
                //delete existing category
                let groceryRef = store.collection(groceryListPath).document(exisingCategory.id!)
                batch.deleteDocument(groceryRef)
                
                if newRecipeGroceryList[index].name == "canned vegetables" {
                    print("stop here")
                }
                
                //merge grocery items in the same category
                exisingCategory.groceryItems = exisingCategory.groceryItems.filter { !newRecipeGroceryList[index].groceryItems.contains($0) }
                
                //add back upated category with less grocery items back to store
                if exisingCategory.groceryItems.count > 0 {
                    let groceryRef = store.collection(groceryListPath).document()
                    do {
                        try _ = batch.setData(from: exisingCategory, forDocument: groceryRef)
                    } catch {
                        fatalError("Unable to delete \(recipe.label) to grocery list: \(error.localizedDescription).")
                    }
                }
            }
        }
            
        // Commit the batch
        batch.commit() { err in
            if let err = err {
                print("Error deleting recipe - \(err)")
            } else {
                print("Batch operation for deleting recipe succeeded.")
            }
        }
        
    }
    
    ///Empty grocery list.
    ///Delete all docs in a colleciton using batch is referenced from this post:
    ///https://stackoverflow.com/questions/53089517/how-to-delete-all-documents-in-collection-in-firestore-with-flutter
    func emptyGroceryList() {
        let batch = store.batch()
        
        //empty a category from grocery list
        for category in groceryList {
            guard let groceryCategoryId = category.id else { return }
            
            let document = store.collection(groceryListPath).document(groceryCategoryId)
            batch.deleteDocument(document)
        }
        batch.commit(){ err in
            if let err = err {
                print("Error to empty grocey list - \(err)")
            } else {
                print("Batch operation for emptying grocery list succeeded.")
            }
        }
    }

    ///Sort grocery list alphabetically by its category first, then sort each item within that category alphabetically
    func sortAndCleanGroceryList() {
        print("#1")
        for index in 0..<groceryList.count {
            print("   \(groceryList[index].name):\(groceryList[index].groceryItems.count)")
        }
        
        for index in 0..<groceryList.count {
            if index < groceryList.count {
                if groceryList[index].groceryItems.count == 0 {
                    groceryList.remove(at: index)
                } else {
                    groceryList[index].groceryItems.sort(by: {$0.name < $1.name})
                }
            }
        }
        groceryList.sort(by: {$0.name.capitalized < $1.name.capitalized})
    }
    
    ///Toggle a grocery item in grocery list
    ///In parameter `item`: GroceryItem - the item's bought/not-bought status to be toggled.
    ///          `category`: GroceryCategory - the category the item belongs to
    func toggleGroceryItem(item:GroceryItem, category:GroceryCategory){
        let groceryRef = store.collection(groceryListPath).document(category.id!) //TODO: !
        
        toggleIsReady = false
        var groceryItems:[GroceryItem] = category.groceryItems
        var newItem = item
        newItem.bought.toggle()
        
        groceryItems = groceryItems.filter( {$0 != item})
        groceryItems.append(newItem)
        

        let batch = store.batch()
        let encodedGroceryItems = groceryItems.compactMap { try? Firestore.Encoder().encode($0) }

        batch.updateData(["groceryItems":encodedGroceryItems], forDocument: groceryRef)
    
        batch.commit(){ err in
            if let err = err {
                print("Error toggling grocery item- \(err)")
            } else {
                self.sortAndCleanGroceryList()
                self.toggleIsReady = true
                print("Batch operation for toggle grocery item succeeded.")
            }
        }
    }
    
    ///Force any view that has this class as an observedObject to refresh    ///Add a recipe to meal plan.  When a recipe is added  to meal plan, its ingredients are added to grocery list.
    ///In parameter: `recipe`:Recipe -- the recipe to be added
    ///
    func updateView(){
        self.objectWillChange.send()
    }
    
}
