//
//  GroceryView.swift
//
//
///This view shows grocery items from meal plan.
///It lists grocery item by category and list them alphabetically.
///When a  recipe is added/deleted from the meal plan, its ingredients are added/deleted from the grocery list.
///If user empty meal plan, then grocey list is emptied too.   However to empty grocery list does not affect mealplan.
///User can check which recipe the grocery item belongs to by clicking on the item.
///user can also check if an item is ready by clicking on the check box next to the item.
///
import SwiftUI

struct GroceryView: View {
    @ObservedObject var groceryListViewModel = GroceryListViewModel.shared
    @State var selectedRecipe : Recipe? = nil
    @State var alertPresented = false
    
    var body: some View {

            VStack {
                HStack{
                    Text("Grocery List")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .padding()
                    
                    Button(action: {
                        alertPresented.toggle()
                    }, label: {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width:25, height: 25)
                    })
                    .disabled(groceryListViewModel.groceryList.count == 0)
                    .alert(isPresented: $alertPresented, content: {
                        Alert(title: Text("Are you sure to empty grocery list?"),
                              primaryButton: .default(Text("Yes"),action: {
                            groceryListViewModel.emptyGroceryList()
                        }),
                              secondaryButton: .cancel(Text("Cancel")))
                    })
                }
                
                List{
                    ForEach(groceryListViewModel.groceryList.indices, id: \.self) { index in
                            categoryView(categoryViewModel: groceryListViewModel.groceryList[index], selectedRecipe: $selectedRecipe)
                    }
                }
                Spacer()
            }
        .onAppear{
            groceryListViewModel.sortAndClean()
        }
        .sheet(item: $selectedRecipe) { item in     // activated on selected item
            RecipeView(recipe: item)   //TODO: !
                .presentationDetents([.large])
        }
    }
}

///This view displays a single category of groceries
///The category is displayed in captial letters, each grocery item belongs to it is displayed alphabetically under it.
struct categoryView: View {
    @ObservedObject var groceryListViewModel = GroceryListViewModel.shared
    var categoryViewModel:GroceryCategoryViewModel
    @Binding var selectedRecipe: Recipe?
    
    var body: some View {
        Section("\(categoryViewModel.groceryCategory.name)") {
            VStack (alignment: .leading){
                
                if groceryListViewModel.isToggleReady() {
                    ForEach(categoryViewModel.groceryCategory.groceryItems) {item in
                        
                        HStack{
                            Button(action: {
                                groceryListViewModel.toggle(item)
                            },
                                   label: {Image(systemName: item.bought ? "checkmark.square.fill" : "square")
                                //label: {Image(systemName: isBought(item) ? "checkmark.square.fill" : "square")
                            })
                            .buttonStyle(.borderless)
                            
                            Text(item.name)
                            Spacer()
                            Text(item.quantityDisplay)
                            Text(item.measure ?? "")
                        }
                        
                        .foregroundColor(.black)
                        .onTapGesture {
                            selectedRecipe = item.recipe
                        }
                    }
                }
            }
        }
    }
    
    func isBought(_ item: GroceryItem) -> Bool {
        if groceryListViewModel.isToggleReady() {
            return item.bought
        } else {
            if item.bought {
                return false
            } else {
                return true
            }
        }
    }
}

struct GroceryView_Previews: PreviewProvider {
    static var previews: some View {
        GroceryView()
    }
}
