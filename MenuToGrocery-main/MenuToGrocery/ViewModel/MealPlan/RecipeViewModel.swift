//
// RecipeViewModel.swift
//
//
/// This class is the view model for  a single grocery category in grocery list
/// The purpose of this class is to help decoding GroceryCategory when a grocery list is retrieved from Firestore.
///
import Foundation
import Combine

class RecipeViewModel: ObservableObject, Identifiable, Hashable {
    private let firebaseRepository = FirebaseRepository()
    @Published var recipe: Recipe
    private var cancellables: Set<AnyCancellable> = []
    
    var id = ""
    
    init(recipe: Recipe) {
        self.recipe = recipe
        $recipe
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
    }
    
    static func == (lhs: RecipeViewModel, rhs: RecipeViewModel) -> Bool {
        lhs.recipe == rhs.recipe &&
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(recipe)
        hasher.combine(id)
    }
}
