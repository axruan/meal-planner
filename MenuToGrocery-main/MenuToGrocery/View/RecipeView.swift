//
//  SwiftUIView.swift
//
//
///This view displaye a single recipe in details.
///For each recipe, the following information is displayed vertically:
/// name, cuisine type, total calories, prepare time, a bigger picture and ingredients.
///
/// At the bottom of the screen, it has "Instruciton" button, it opens up an external  webpage.
/// At the top fo the screen, 2 buttons are shown, one for meal pland, the other favorite recipes.
/// If the recipe is in meal plan, then meal plan icon is shown red, otherwise green.
/// If the recipe is in favorite recipes, a red heart is shown, otherwrise heart icon is green.
/// User can toggle these 2 icons to add/remove from meal plan or favorite recipes.
///
import SwiftUI
import WebKit

let roundCircleButtonWidth = 30.0

struct RecipeView: View {
    @ObservedObject var favoriteViewModel = FavoriteViewModel.shared
    @ObservedObject var mealViewModel = MealPlanViewModel.shared
    @State var showInstruction = true
    
    var recipe: Recipe
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    AddToMealPlanAndFavoriteButtons(recipe: recipe)
                }
                .padding(.top, 10)
                
                Text("\(recipe.label)")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                Text("Cuisine: \(recipe.mainCuisineType.capitalized)") //TODO: check if this optional field
                    .font(.system(size: 20, design: .rounded))
                Text("Calories: \(Int(recipe.calories))")
                Text("Prepare time: \(Int(recipe.totalTime)) mins")
                
                AsyncImage(
                    url: URL(string: "\(recipe.images.small.url)"),
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 200, maxHeight: 200)
                    },
                    placeholder: {
                        Text("Loading...")
                            .frame(maxWidth: 200, maxHeight: 200)
                    }
                )
                .padding()
                
                List {
                    Section("Ingredients") {
                        ForEach(recipe.ingredients) { ingredient in
                            VStack{
                                Text(ingredient.text.capitalized)
                                    .foregroundColor(.blue)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding([.leading,.trailing],10 )
                
                Spacer()
                
                NavigationLink(destination: WebView(url: URL(string: recipe.url)!, showWebView: $showInstruction)) {
                    Text("Instructions")
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
        }
    }
}

///This view presents a web page from a passed in URL
///In parameter: `url`: URL -- url for the web page
///code reference: https://medium.com/geekculture/how-to-use-webview-in-swiftui-and-also-detect-the-url-21d4fab2a9c1
struct WebView: UIViewRepresentable {
    var url: URL
    @Binding var showWebView: Bool
 
    func makeUIView(context: Context) -> WKWebView {
        let wKWebView = WKWebView()
        wKWebView.navigationDelegate = context.coordinator
        return wKWebView
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(self)
    }
    
    class WebViewCoordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            let urlToMatch = "https://workshop.appcoda.com/"
            if let urlStr = navigationAction.request.url?.absoluteString, urlStr == urlToMatch {
                parent.showWebView = false
            }
            decisionHandler(.allow)
        }
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(recipe: Recipe.sample(index: 0))
    }
}
