/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Data source for the number of solar panels in the habitat.
*/

import Foundation

struct SolarPanelDataSource {
    /// Possible values for solar panels in the habitat
    private let values = [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5]
    
    var items: Int {
        return values.count
    }
    
    func title(for index: Int) -> String? {
        guard index < values.count else { return nil }
        return String(values[index])
    }
    
    func value(for index: Int) -> Double? {
        guard index < values.count else { return nil }
        return Double(values[index])
    }
}
