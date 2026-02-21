import SwiftUI

@main
struct VINScoutApp: App {

    /// Single ViewModel instance shared across the entire app via the environment.
    @StateObject private var viewModel = VINScoutViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
                // nil = follow system, .light / .dark = user override
                .preferredColorScheme(viewModel.preferredColorScheme)
        }
    }
}
