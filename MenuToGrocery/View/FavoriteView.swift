//
//  FavoriteView.swift
//
//
///This view shows favorite recipes.
///The recipes in this view is grouped by cuisine type,  Each recipe is represented as a small image.
///User can empty favorite recipes by clicking on trash can image at the top right of screen
///
///By clicking on an individual recipe image, it leads to a detailed recipe screen. From there user can add/remove
///the recipe from meal plan.
///
import SwiftUI

struct FavoriteView: View {
    @ObservedObject var viewModel = FavoriteViewModel.shared
    @State var selectedRecipe : Recipe? = nil
    @State var alertPresented = false
    var body: some View {
        
        VStack{
            HStack {
                Text("Favorite Recipes")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .padding()
                
                Button(action: {
                    alertPresented.toggle()
                }, label: {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width:25, height: 25)
                })
                .disabled(viewModel.favorites.count == 0)
                .alert(isPresented: $alertPresented, content: {
                    Alert(title: Text("Are you sure to empty favorite meals?"),
                primaryButton: .default(Text("Yes"),action: {
                        viewModel.emptyFavorites()
                    }),
                secondaryButton: .cancel(Text("Cancel")))
                })
            }
            
            ScrollView(.vertical) {
                ForEach(viewModel.favorites) { cuisineViewModel in
                    VStack (alignment: .leading){
                        //cuisine type
                        Text("\(cuisineViewModel.recipeByCuisineType.cuisineType.capitalized)")
                            .font(.system(size: 24, weight: .semibold))
                        
                        //recipes belong to the cuisine
                        ScrollView(.horizontal) {
                            HStack(spacing: 20) {
                                ForEach(cuisineViewModel.recipeByCuisineType.recipes) { r in
                                    
                                    VStack {
                                        Text("\(r.label)")
                                            .font(.system(size: 12))
                                            //.fixedSize(horizontal: false, vertical: false)
                                            .frame(width: recipeWidth, height: 20)
                                            .truncationMode(.tail)
                                            
                                        ZStack{
                                            AsyncImage(
                                                url: URL(string: "\(r.images.small.url)"),
                                                content: { image in
                                                    image.resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(maxWidth: recipeWidth, maxHeight: recipeWidth)
                                                    
                                                },
                                                placeholder: {
                                                    Text("Loading...")
                                                        .frame(maxWidth: recipeWidth, maxHeight: recipeWidth)
                                                    
                                                }
                                            )
                                            
                                            //delete button
                                            VStack{
                                                HStack{
                                                    Spacer()
                                                    Button(action: {
                                                        viewModel.remove(r)
                                                    },
                                                           label: {
                                                        Image(systemName: "multiply")
                                                            .resizable()
                                                            .frame(width:deleteSignWidth, height:deleteSignWidth)
                                                            .foregroundColor(Color.white)
                                                        
                                                    })
                                                    .background(.blue.opacity(0.6))
                                                    .cornerRadius(40)
                                                    .shadow(color: Color.black.opacity(0.3),
                                                            radius: 3,
                                                            x: 3,
                                                            y: 3)
                                                }
                                                Spacer()
                                            }
                                            .frame(width: recipeWidth, height: recipeWidth)
                                        }
                                    }
                                    .onTapGesture {
                                        selectedRecipe = r
                                    }
                                    
                                    
                                }
                                .frame(width: recipeWidth+5, height: recipeWidth+55)
                            }
                        }
                    }
                }
                .padding([.leading,.trailing], 15)
                
            }
            
            Spacer()
            Spacer()
        }
        .sheet(item: $selectedRecipe) { item in     // activated on selected item
            RecipeView(recipe: item)
                .presentationDetents([.large])
        }
    }
}
struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView()
    }
}
