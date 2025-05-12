import Foundation
import os.log

class LogService {
    static let shared = LogService()
    private let logger: Logger
    
    private init() {
        logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.empathyapp", category: "Auth")
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.info("\(message)")
        print("[INFO] \(message)")
    }
    
    func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        if let error = error {
            logger.error("\(message): \(error.localizedDescription)")
            print("[ERROR] \(message): \(error.localizedDescription)")
        } else {
            logger.error("\(message)")
            print("[ERROR] \(message)")
        }
    }
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.debug("\(message)")
        print("[DEBUG] \(message)")
    }
} 