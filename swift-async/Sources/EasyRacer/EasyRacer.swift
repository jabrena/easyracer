import Foundation

extension URLSession {
    func bodyText(from url: URL) async throws -> String {
        let (data, response) = try await data(from: url)
        
        guard
            let response = response as? HTTPURLResponse,
            (200..<300).contains(response.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
        
        guard
            let text: String = String(data: data, encoding: .utf8)
        else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return text
    }
}

@main
public struct EasyRacer {
    let baseURL: URL
    let urlSession: URLSession = ScalableURLSession(
        configuration: {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.httpMaximumConnectionsPerHost = 1_000
            configuration.timeoutIntervalForRequest = 120
            return configuration
        }(),
        requestsPerSession: 100,
        timeIntervalBetweenRequests: 0.05 // 50ms
    )

    func scenario1() async -> String? {
        let url: URL = baseURL.appendingPathComponent("1")
        
        let result: String? = await withTaskGroup(of: String?.self) { group in
            defer { group.cancelAll() }
            
            group.addTask { try? await urlSession.bodyText(from: url) }
            group.addTask { try? await urlSession.bodyText(from: url) }
            
            return await group.first { $0 != nil }.flatMap { $0 }
        }
        
        return result
    }
    
    func scenario2() async -> String? {
        let url: URL = baseURL.appendingPathComponent("2")
        
        let result: String? = await withTaskGroup(of: String?.self) { group in
            defer { group.cancelAll() }
            
            group.addTask { try? await urlSession.bodyText(from: url) }
            group.addTask { try? await urlSession.bodyText(from: url) }
            
            return await group.first { $0 != nil }.flatMap { $0 }
        }
        
        return result
    }
    
    func scenario3() async -> String? {
        let url: URL = baseURL.appendingPathComponent("3")
        
        let result: String? = await withTaskGroup(of: String?.self) { group in
            defer { group.cancelAll() }
            
            for _ in 1...10_000 {
                group.addTask {
                    return try? await urlSession.bodyText(from: url)
                }
            }
            
            return await group.first { $0 != nil }.flatMap { $0 }
        }
        
        return result
    }
    
    func scenario4() async -> String? {
        let url: URL = baseURL.appendingPathComponent("4")
        let urlSession1SecTimeout: URLSession = Foundation.URLSession(configuration: {
            let configuration: URLSessionConfiguration = .ephemeral
            configuration.timeoutIntervalForRequest = 1
            return configuration
        }())
        
        let result: String? = await withTaskGroup(of: String?.self) { group in
            defer { group.cancelAll() }
            
            group.addTask { try? await urlSession.bodyText(from: url) }
            group.addTask { try? await urlSession1SecTimeout.bodyText(from: url) }
            
            return await group.first { $0 != nil }.flatMap { $0 }
        }
        
        return result
    }
    
    func scenario5() async -> String? {
        let url: URL = baseURL.appendingPathComponent("5")
        
        let result: String? = await withTaskGroup(of: String?.self) { group in
            defer { group.cancelAll() }
            
            group.addTask { try? await urlSession.bodyText(from: url) }
            group.addTask { try? await urlSession.bodyText(from: url) }
            
            return await group.first { $0 != nil }.flatMap { $0 }
        }
        
        return result
    }
    
    func scenario6() async -> String? {
        let url: URL = baseURL.appendingPathComponent("6")
        
        let result: String? = await withTaskGroup(of: String?.self) { group in
            defer { group.cancelAll() }
            
            group.addTask { try? await urlSession.bodyText(from: url) }
            group.addTask { try? await urlSession.bodyText(from: url) }
            group.addTask { try? await urlSession.bodyText(from: url) }
            
            return await group.first { $0 != nil }.flatMap { $0 }
        }
        
        return result
    }
    
    func scenario7() async -> String? {
        let url: URL = baseURL.appendingPathComponent("7")
        
        let result: String? = await withTaskGroup(of: String?.self) { group in
            defer { group.cancelAll() }
            
            group.addTask { try? await urlSession.bodyText(from: url) }
            group.addTask {
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                return try? await urlSession.bodyText(from: url)
            }
            
            return await group.first { $0 != nil }.flatMap { $0 }
        }
        
        return result
    }
    
    func scenario8() async -> String? {
        let url: URL = baseURL.appendingPathComponent("8")
        @Sendable func doOpenUseAndClose() async throws -> String {
            guard
                let urlComps: URLComponents = URLComponents(
                    url: url, resolvingAgainstBaseURL: false
                )
            else {
                throw URLError(.badURL)
            }
            
            // Open
            var openURLComps = urlComps
            openURLComps.queryItems = [URLQueryItem(name: "open", value: nil)]
            
            guard
                let openURL: URL = openURLComps.url
            else {
                throw URLError(.badURL)
            }
            let id = try await urlSession.bodyText(from: openURL)
            
            // Use
            var useURLComps = urlComps
            useURLComps.queryItems = [URLQueryItem(name: "use", value: id)]
            
            guard
                let useURL: URL = useURLComps.url
            else {
                throw URLError(.badURL)
            }
            let text: String? = try? await urlSession.bodyText(from: useURL)
            
            // Close
            var closeURLComps = urlComps
            closeURLComps.queryItems = [URLQueryItem(name: "close", value: id)]
            
            guard
                let closeURL: URL = closeURLComps.url
            else {
                throw URLError(.badURL)
            }
            let _ = try await urlSession.data(from: closeURL)
            
            guard let text: String = text else {
                throw URLError(.badServerResponse)
            }
            return text
        }
        
        let result: String? = await withTaskGroup(of: String?.self) { group in
            defer { group.cancelAll() }
            
            group.addTask { try? await doOpenUseAndClose() }
            group.addTask { try? await doOpenUseAndClose() }
            
            return await group.first { $0 != nil }.flatMap { $0 }
        }
        
        return result
    }
    
    func scenario9() async -> String? {
        let url: URL = baseURL.appendingPathComponent("9")
        
        let result: String? = await withTaskGroup(of: String?.self) { group in
            defer { group.cancelAll() }
            
            for _ in 1...10 {
                group.addTask { try? await urlSession.bodyText(from: url) }
            }
            
            return await group
                .compactMap { $0 }
                .reduce("") { $0 + $1 }
        }
        
        return result
    }
    
    public func scenarios() async -> [String?] {
        [
            (1, await scenario1()),
            (2, await scenario2()),
            (4, await scenario4()),
            (5, await scenario5()),
            (6, await scenario6()),
            (7, await scenario7()),
            (8, await scenario8()),
            (9, await scenario9()),
            (3, await scenario3()), // This has to come last, as it frequently causes other scenarios to fail
        ].sorted { $0.0 < $1.0 }.map { $0.1 }
    }
    
    public static func main() async throws {
        guard
            let baseURL = URL(string: "http://localhost:8080")
        else { return }
        
        let results = await EasyRacer(baseURL: baseURL).scenarios()
        for (idx, result) in results.enumerated() {
            print("Scenario \(idx + 1): \(result ?? "error")")
        }
        exit(results.allSatisfy { $0 != nil } ? EXIT_SUCCESS : EXIT_FAILURE)
    }
}
