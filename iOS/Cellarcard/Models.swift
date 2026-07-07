import Foundation

struct BottleEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var vintage: String
    var drinkByYear: String
    var notes: String

    init(id: UUID = UUID(), name: String = "", vintage: String = "", drinkByYear: String = "", notes: String = "") {
        self.id = id
        self.name = name
        self.vintage = vintage
        self.drinkByYear = drinkByYear
        self.notes = notes
    }
}
