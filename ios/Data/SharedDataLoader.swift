import Foundation

class SharedDataLoader {
    static func loadJson(from fileName: String) -> [String: Any]? {
        guard let path = Bundle.main.path(forResource: "shared/data/" + fileName, ofType: nil) else { return nil }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return json
        } catch {
            print("Error loading JSON: \(error)")
            return nil
        }
    }
}
