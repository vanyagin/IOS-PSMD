import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Lab6")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    public func fetchPokemon(by name: String) -> Pokemon? {
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)

        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Fetching \(name) failed")
            return nil
        }
    }
    
    public func createPokemon(name: String, height: Int16, weight: Int16, url: String) {
        let context = PersistenceController.shared.container.newBackgroundContext()
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        context.performAndWait {
            let newPokemon = Pokemon(context: context)
            newPokemon.name = name
            newPokemon.height = height
            newPokemon.weight = weight
            newPokemon.url = url
            do {
                try context.save()
            } catch {
                print("Failed to create pokemon")
            }
        }
    }
    
    public func updatePokemon(with name: String, height: Int16, weight: Int16, url: String) {
        let context = PersistenceController.shared.container.newBackgroundContext()
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        do {
            guard let pokemons = try? context.fetch(fetchRequest) as [Pokemon],
                  let pokemon = pokemons.first(where: { $0.name == name }) else { return }
            pokemon.height = height
            pokemon.weight = weight
            pokemon.url = url
        }
        do {
            try context.save()
        } catch {
            print("Failed to update \(name) pokemon")
        }
    }
    
    public func deleteAllPokemon() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        do {
            let pokemons = try? context.fetch(fetchRequest) as [Pokemon]
            pokemons?.forEach { context.delete($0) }
        }
        do {
            try context.save()
        } catch {
            print("Failed to delete all pokemons")
        }
    }
    
}
