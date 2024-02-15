//
//  ContentView.swift
//
//
///This is the entry view of the app.  It shows 4 tabs: Search, MealPlan, Favorites and Grocery List
///
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
           MealPlanView()
                .tabItem {
                    Label("Mean Plan", systemImage: "book")
                }
            
            FavoriteView()
                 .tabItem {
                     Label("Favorite", systemImage: "heart")
                 }
            GroceryView()
                 .tabItem {
                     Label("Grocery List", systemImage: "list.dash")
                 }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
