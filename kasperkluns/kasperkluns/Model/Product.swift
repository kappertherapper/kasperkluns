enum Brand: String, Codable, CaseIterable, Identifiable {
    case NewBalance = "NewBalance"
    case Nike = "Nike"
    case Salomon = "Salomon"
    case adidas = "adidas"
    case Asics = "Asics"
    
    var id: String { self.rawValue }
}
