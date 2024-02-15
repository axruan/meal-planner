//
//  AdviceView.swift
//
//
///This views allows user to consult chatGPT on their meal plan.
///The view allows user to choose sex and age, then by cicking on the blue button, user's mealplan is sent to chatGPT for consulation.
///Whie waiting for chatGPT response, a loading indicator is shown.  Once response is back,  the loading indicator disappears
///and existing screen is replaced with chatGPT answer.
///User can ask chatGPT once when the half sheet is presented.  If user wants to ask again, the advice screen has to be reinvoked by clicking
///on "Advice" image on Meal Plan screen. 
///
import SwiftUI

struct AdviceView: View {
    @ObservedObject var mealViewModel = MealPlanViewModel.shared
    @ObservedObject var chatGPTViewModel = ChatGPTViewModel.shared
    @State private var age:Int = 17
    @State private var sexSelection = "Female"
    let sexList = ["Male", "Female"]
    @State private var number: Int = 1
    @State private var isChecking = false
    
    var body: some View {
        ZStack {
            if isChecking && !chatGPTViewModel.hasAdvice() {
                VStack{
                    Spacer()
                    Spacer()
                    ProgressView()
                        .padding(10)
                    Text("loading...")
                        .bold()
                    Spacer()
                }
                
            }
            
            VStack {
                Capsule()
                    .fill(Color.secondary)
                    .frame(width: 50, height: 3)
                
                if !chatGPTViewModel.hasAdvice() {
                    Form {
                        Picker(selection: $sexSelection, label: Text("Sex")) {
                            ForEach(sexList, id: \.self) {
                                Text($0)
                            }
                            .pickerStyle(.menu)
                        }
                        Picker(selection: $age, label: Text("Your age")) {
                            ForEach(1...100, id: \.self) { number in
                                Text("\(number)")
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .frame(height: 140)
                }
                
                Button(action: {
                    isChecking = true
                    self.chatGPTViewModel.getMealPlanAdvice(mealPlan: mealViewModel.getRecipesForAdvice(),
                                                            age:age,
                                                            sex:sexSelection)
                }) {
                    //Text("Consult chatGPT on your meal plan")
                    Text(chatGPTViewModel.hasAdvice() ? "Answer" : "Consult ChatGPT on your meal plan")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.white)
                }
                .background(chatGPTViewModel.hasAdvice() ? .green: .blue)
                .cornerRadius(20)
                .disabled(!mealViewModel.readyForAdvice() || chatGPTViewModel.hasAdvice())
                .padding(.top, chatGPTViewModel.hasAdvice() ? 10 : 5)
                
                
                //chatGPT answer
                Text("\(chatGPTViewModel.advice)")
                    .frame(width: UIScreen.screenWidth - 80)
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                
                Spacer()
                Spacer()
                
            }
            .frame(width:UIScreen.screenWidth - 20)
            .onAppear{
                chatGPTViewModel.emptyAdvice()
                isChecking = false
            }
        }
    }
}

struct AdviceView_Previews: PreviewProvider {
    static var previews: some View {
        AdviceView()
    }
}
