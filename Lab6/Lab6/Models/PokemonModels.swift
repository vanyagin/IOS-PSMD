struct PokemonList: Decodable {
    let results: [PokemonPreview]
}

struct PokemonPreview: Decodable, Equatable {
    let name: String
    let url: String

}

struct PokemonDetails: Decodable {
    let height: Int16
    let name: String
    let weight: Int16
    let url: String

    
    enum CodingKeys: String, CodingKey {
        case height, name, weight, sprites, stats
        
        enum SpritesKeys: String, CodingKey {
            case other
            
            enum OtherKeys: String, CodingKey {
                case officialArtwork = "official-artwork"
                
                enum OfficialArtworkKeys: String, CodingKey {
                    case officialArtUrl = "front_default"
                }
            }
        }
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        height = try container.decode(Int16.self, forKey: .height)
        name = try container.decode(String.self, forKey: .name)
        weight = try container.decode(Int16.self, forKey: .weight)
        
        let spritesContainer = try container.nestedContainer(keyedBy: CodingKeys.SpritesKeys.self, forKey: .sprites)
        let otherContainer = try spritesContainer.nestedContainer(keyedBy: CodingKeys.SpritesKeys.OtherKeys.self, forKey: .other)
        url = try otherContainer.nestedContainer(keyedBy: CodingKeys.SpritesKeys.OtherKeys.OfficialArtworkKeys.self, forKey: .officialArtwork).decode(String.self, forKey: .officialArtUrl)

    }
}
