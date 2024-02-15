//
// EdamamNetworkManager.swift
//
//
///This class is responsible to talk to Edamam API to get recipes. It uses Combine to conduct async fetch from Edamam.
///Edamam recipe search API website is https://developer.edamam.com/edamam-recipe-api
///The recipe search accepts a query as a string dictionary, returns the default response type defined by Edamam .
///
import Foundation
import Combine

class EdamamNetworkManager{
    
    static let shared = EdamamNetworkManager()
    
    private init() {
    }
    
    private var cancellables = Set<AnyCancellable>()

    let recipeURL = "https://api.edamam.com/api/recipes/v2"
    let recipeAPIKey =  "ec15d9485c640350d358f7c6c4cd2816"//"4ed5ca518b3756cbc0701d7501264aa8"
    let recipeAPIID = "d41cb358"//"60774aad" //"6b423b50"
    
    ///Search recipe based on passed-in query, returns a generic type defined by the caller
    ///In parameter:
    ///         `endpoint`:String - the endpoint of search API for Emamam
    ///         `query`: [String:String] - a list of string dictionary, e.g. APIkey, cuisine type, meal type..etc
    ///         `type`: <T: Decodable> - a generic return type defined by the caller
    /// Return:
    ///         `Future<T, Error>`: a generic return type defined by the caller
    func getRecipe<T: Decodable>(endpoint: String, query: [String:String], type: T.Type) -> Future<T, Error> {
        return Future<T, Error> { [weak self] promise in

            guard let self = self,
                  var urlComponents = URLComponents(string: endpoint) else {
                return promise(.failure(NetworkError.invalidURL))
            }
            
            //https://api.edamam.com/api/recipes/v2?type=public&beta=false&q=crawfish%20etouffee&app_id=60774aad&app_key=4ed5ca518b3756cbc0701d7501264aa8&ingr=5-8&diet=high-protein&cuisineType=American&mealType=Dinner&calories=100-300&imageSize=THUMBNAIL

            urlComponents.queryItems=[URLQueryItem(name:"type", value:"public"),
                                      URLQueryItem(name:"beta", value:"false"),
                                      URLQueryItem(name:"app_key",value:self.recipeAPIKey),
                                      URLQueryItem(name:"app_id", value:self.recipeAPIID)]
           
            for (key, value)  in query {
                let item = URLQueryItem(name: key, value:value)
                urlComponents.queryItems?.append(item)
            }
           
            guard let url = urlComponents.url else {
                return promise(.failure(NetworkError.invalidURL))
            }

            //decode date to correct format
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            print(url)
            
            URLSession.shared.dataTaskPublisher(for: url)
            //URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw NetworkError.responseError
                    }
                    data.printJSON()
                    return data
                }
                .decode(type: T.self, decoder: decoder)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (completion) in
                    if case let .failure(error) = completion {
                        switch error {
                        case let decodingError as DecodingError:
                            promise(.failure(decodingError))
                        case let apiError as NetworkError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(NetworkError.unknown))
                        }
                    }
                }, receiveValue: { promise(.success($0)) })
                .store(in: &self.cancellables)
        }
    }
}
