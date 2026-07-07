import Foundation

struct GearItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var itemName: String
    var size: String
    var date: Date = Date()
}
