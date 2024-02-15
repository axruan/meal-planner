//
//SearchViewModel.swift
//
//
///This is the view model to search recipes.
///It uses Combine to get data from Edamam API site.  The API response is translated to an array of Recipe consumed by Search view.
///
import Foundation
import Combine

class SearchViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    @Published var geoCode = "..."
    @Published var recipes = [Recipe]()
    @Published var searched = false
    static let shared = SearchViewModel()
    private init() {}
    
    //MARK: Edamam API services
    func getRecipe(search: String, cuisineType: String?, mealType: String?) {
                
        /* sample data
         https://api.edamam.com/api/recipes/v2?type=public&
        beta=false&
         q=crawfish%20etouffee&
         app_id=60774aad&
         app_key=4ed5ca518b3756cbc0701d7501264aa8&
         ingr=5-8&
         diet=high-protein&
         cuisineType=American&
         mealType=Dinner&
         calories=100-300&
         imageSize=THUMBNAIL
         */
        var query:[String:String] = ["beta": "false",
                                     "q":search,
                                     "ingr":"5-8",
                                     "calories":"100-300",
                                     "imageSize":"THUMBNAIL"]
        if let t = cuisineType, !t.isEmpty, t != "empty" {
            query["cuisineType"] = cuisineType
        }
        
        if let t = mealType, !t.isEmpty, t != "empty" {
            query["mealType"] = mealType
        }
        
        EdamamNetworkManager.shared.getRecipe(endpoint: "\(EdamamNetworkManager.shared.recipeURL)",
                                              query: query,
                                              type: RecipeResponse.self)
        .sink { completion in
            switch completion {
            case .failure(let err):
                print("getRecipe Error is \(err.localizedDescription)")
            case .finished:
                print("getRecipe Finished")
            }
        }
    receiveValue: { [weak self] response in
        self?.recipes = response.hits.compactMap{$0.recipe}
        self?.searched = true
    }
    .store(in: &self.cancellables)
    }
}
