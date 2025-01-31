import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = PokemonListViewModel()
    @StateObject var detailsViewModel = PokemonDetailsViewModel()
    @State var selection: String? = nil
    
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        
        GeometryReader{ geometry in
            VStack{
                NavigationView {
                    ScrollView{
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(viewModel.pokemons, id: \.name) { pokemon in
                                NavigationLink(destination: DetailsView(name: pokemon.name), tag: pokemon.name, selection: $selection) {
                                    PokemonPixelView(id: viewModel.getIndex(pokemon), cellSize: geometry.size.width, name: pokemon.name, selection: $selection)
                                }
                            }
                        }
                    }
                    .navigationTitle("Pokemon List")
                    .navigationBarTitleDisplayMode(.inline)
                    .alert(item: $viewModel.alertItem) { alertItem in
                        Alert(title: alertItem.title, message: alertItem.message, dismissButton: .default(alertItem.buttonTitle,  action:{Task { await viewModel.getPokemons()}}))
                    }
                }
                .environmentObject(detailsViewModel)
                .navigationViewStyle(.stack)
            }
        }
    }
}
