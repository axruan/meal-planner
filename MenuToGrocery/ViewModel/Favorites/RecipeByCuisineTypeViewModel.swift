//
// RecipeByCuisineTypeViewModel.swift
//
//
/// This class is the view model for  a single cuisine type in favorite recipe list
/// The purpose of this class is to help decoding RecipeByCuisineType when a favorite recipe list is retrieved from Firestore.
///
import Foundation
import Combine

class RecipeByCuisineTypeViewModel: ObservableObject, Identifiable, Hashable {

    private let firebaseRepository = FirebaseRepository()
    @Published var recipeByCuisineType: RecipeByCuisineType
    private var cancellables: Set<AnyCancellable> = []
    
    var id = ""
    
    init(recipeByCuisineType: RecipeByCuisineType) {
        self.recipeByCuisineType = recipeByCuisineType
        $recipeByCuisineType
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
    }
    
    static func == (lhs: RecipeByCuisineTypeViewModel, rhs: RecipeByCuisineTypeViewModel) -> Bool {
        lhs.recipeByCuisineType.cuisineType ==  rhs.recipeByCuisineType.cuisineType
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(recipeByCuisineType.cuisineType)
    }
}

