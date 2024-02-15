//
// ChatRequestManager.swift
//
//
///This class is responsible to send a meal plan question to chatGPT and get chatGPT's comment on the meal plan.
///It uses Combine to fetch response from chatGPT
///
import Foundation
import Combine

class ChatRequestManager: ObservableObject {
    
    static let shared = ChatRequestManager()
    
    private init() {
    }
    
    
    private var cancellables = Set<AnyCancellable>()
    
    
    ///Get chatGPT comment on selected meal plan
    ///In Parameter:
    ///         `mealPlan`:String - a list of recipes seperated by comma
    ///         `age`:Int - meal plan owner's age
    ///         `sex`: String - meal plan owner's sex
    ///         `type`: <T: Decodable> - a decodable generic response from ChatGPT
    ///Return:
    ///     `Future<T, Error>`  -- a decodable generic response from ChatGPT
    func makeRequest<T: Decodable>(mealPlan: String, age: Int, sex: String, type: T.Type) -> Future<T, Error> {
        return Future<T, Error> { [weak self] promise in
            
            guard let self = self else {
                return promise(.failure(NetworkError.invalidURL))
            }
            
            let apiKey = "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"
            let model = "text-davinci-003"
            let prompt = "I am \(age) year old \(sex), here is my mealplan: \(mealPlan), please give brief comment on it, no need to list individual recipe, just overal impression"
            let temperature = 0.9
            let maxTokens = 1024
            let topP = 1
            let frequencyPenalty = 0.0
            let presencePenalty = 0.6
            let stop = [" Human:", " AI:"]
            
            let requestBody : [String : Any] = [
                "model": model,
                "prompt": prompt,
                "temperature": temperature,
                "max_tokens": maxTokens,
                "top_p": topP,
                "frequency_penalty": frequencyPenalty,
                "presence_penalty": presencePenalty,
                "stop": stop
            ]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)
            
            var request = URLRequest(url: URL(string: "https://api.openai.com/v1/completions")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            
            //decode date to correct format
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw NetworkError.responseError
                    }
                    data.printJSON()
                    return data
                }
                .decode(type: T.self, decoder: decoder)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
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
