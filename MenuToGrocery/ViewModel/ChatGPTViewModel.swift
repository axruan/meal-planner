//
//  ChatGPTViewModel.swift
//
//
///This is the view model to chatGPT advice screen
///It uses Combine to talk to chatGPT, get response back and put it to a published variable named "advice".
///Advice view checks "advice" value and display it to user. 
///
import Foundation
import Combine

class ChatGPTViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    @Published var advice = ""
    static let shared = ChatGPTViewModel()
    
    private init() {
    }
    
    func hasAdvice() -> Bool {
        return !advice.isEmpty
    }
    
    func emptyAdvice() {
        advice = ""
    }
    
    func getMealPlanAdvice(mealPlan: String, age: Int, sex: String){
        ChatRequestManager.shared.makeRequest(mealPlan: mealPlan, age: age, sex: sex, type: ChatResponse.self)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("chatGPT Error is \(err.localizedDescription)")
                case .finished:
                    print("chatGPT advice Finished")
                    
                }
            }
    receiveValue: { [weak self] response in
        if response.choices.count > 0 {
            let answer = response.choices[0].text
            self?.advice =  answer
        }
    }
    .store(in: &self.cancellables)
    }
}
