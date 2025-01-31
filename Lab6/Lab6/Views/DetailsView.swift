import SwiftUI

struct DetailsView: View {
    var pokemonImage: Image?
    let name: String
    @EnvironmentObject var detailsViewModel: PokemonDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    
    //@FetchRequest(entity: Pokemon.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.name, ascending: true)]) var pokes: FetchedResults<Pokemon>
    
    var body: some View {
        GeometryReader {geo in
            VStack{
                ZStack{
                    ScrollView{
                        VStack(spacing: 10){
                            HStack{
                                Text("Weight").foregroundColor(.gray)
                                Spacer()
                                Text("\(detailsViewModel.poke?.weight ?? 0)kg")
                            }
                            HStack{
                                Text("Height").foregroundColor(.gray)
                                Spacer()
                                Text("\(detailsViewModel.poke?.height ?? 0)m")
                            }
                            HStack{
                                AsyncImage(url: URL(string: detailsViewModel.poke?.url ?? "arrow.trianglehead.2.clockwise.rotate.90")) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                            case .failure:
                                                Text("Загрузка...")
                                            @unknown case _:
                                                EmptyView()
                                            }
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }

                        }
                    }.padding(.top).padding(.horizontal,20)
                }
            }
        }
        .navigationTitle(detailsViewModel.poke?.name ?? "Pokemon Detail")
        .alert(item: $detailsViewModel.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: .default(alertItem.buttonTitle){dismiss()})
        }
        .task{
            await detailsViewModel.getPokemonInfo(name)
        }
    }
}
