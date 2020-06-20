import ArgumentParser
import Foundation

struct VendorCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "vendor",
            abstract: "Generates all needed provisioning profiles and certificates "
        )
    }
    
    func run() throws {
        try VendorService().run()
    }
}
