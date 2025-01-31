import SwiftUI

@main
struct Lab6App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .task {
                    PersistenceController.shared.deleteAllPokemon()
                }
        }
    }
}
