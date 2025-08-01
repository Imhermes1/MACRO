import Foundation
import Network

class SyncManager {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    func isOnline(completion: @escaping (Bool) -> Void) {
        monitor.pathUpdateHandler = { path in
            completion(path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    func syncGroups(localStorage: LocalGroupStorage, supabaseService: SupabaseService) {
        isOnline { online in
            if online {
                let localGroups = localStorage.loadGroups()
                localGroups.forEach { supabaseService.saveGroup($0) }
                supabaseService.getGroups { cloudGroups in
                    localStorage.saveGroups(cloudGroups)
                }
            }
        }
    }
}
