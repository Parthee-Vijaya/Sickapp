import Foundation

final class APIClient: APIClientProtocol, @unchecked Sendable {
    private let session: URLSession
    private let authService: AuthServiceProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(authService: AuthServiceProtocol, session: URLSession = .shared) {
        self.authService = authService
        self.session = session

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Manager

    func getMe() async throws -> Manager {
        try await request(.get, url: APIEndpoints.Auth.me)
    }

    func getDirectReports() async throws -> [Employee] {
        let response: GraphResponse<Employee> = try await request(.get, url: APIEndpoints.Auth.directReports)
        return response.value
    }

    func getEmployeePhoto(employeeId: String) async throws -> Data {
        let url = APIEndpoints.Auth.employeePhoto(id: employeeId)
        return try await requestData(.get, url: url)
    }

    // MARK: - Groups

    func getMyGroups() async throws -> [TeamGroup] {
        let response: GraphResponse<TeamGroup> = try await request(.get, url: APIEndpoints.Groups.myGroups)
        return response.value
    }

    func getGroupMembers(groupId: String) async throws -> [Employee] {
        let response: GraphResponse<Employee> = try await request(.get, url: APIEndpoints.Groups.groupMembers(id: groupId))
        return response.value
    }

    // MARK: - Absences

    func createAbsence(_ record: AbsenceRecord) async throws -> AbsenceRecord {
        try await request(.post, url: APIEndpoints.Absences.create, body: record)
    }

    func getAbsences(managerId: String, status: AbsenceStatus?, type: AbsenceType?) async throws -> [AbsenceRecord] {
        var components = URLComponents(string: APIEndpoints.Absences.list)
        var queryItems = [URLQueryItem(name: "managerId", value: managerId)]
        if let status { queryItems.append(URLQueryItem(name: "status", value: status.rawValue)) }
        if let type { queryItems.append(URLQueryItem(name: "type", value: type.rawValue)) }
        components?.queryItems = queryItems

        guard let urlString = components?.string else { throw APIError.invalidURL }
        return try await request(.get, url: urlString)
    }

    func getAbsence(id: String) async throws -> AbsenceRecord {
        try await request(.get, url: APIEndpoints.Absences.detail(id: id))
    }

    func updateAbsence(id: String, endDate: Date?, status: AbsenceStatus?) async throws -> AbsenceRecord {
        let body = UpdateAbsenceBody(endDate: endDate, status: status)
        return try await request(.patch, url: APIEndpoints.Absences.detail(id: id), body: body)
    }

    func cancelAbsence(id: String) async throws {
        let _: EmptyResponse = try await request(.delete, url: APIEndpoints.Absences.detail(id: id))
    }

    func extendAbsence(id: String, newEndDate: Date) async throws -> AbsenceRecord {
        let body = ExtendAbsenceBody(newEndDate: newEndDate)
        return try await request(.post, url: APIEndpoints.Absences.extend(id: id), body: body)
    }

    func getAbsenceStats(managerId: String, period: StatsPeriod) async throws -> AbsenceStats {
        var components = URLComponents(string: APIEndpoints.Absences.stats)
        components?.queryItems = [
            URLQueryItem(name: "managerId", value: managerId),
            URLQueryItem(name: "period", value: period.rawValue)
        ]
        guard let urlString = components?.string else { throw APIError.invalidURL }
        return try await request(.get, url: urlString)
    }

    // MARK: - Notifications

    func sendNotification(absenceId: String, groupId: String) async throws {
        let body = SendNotificationBody(absenceId: absenceId, groupId: groupId)
        let _: EmptyResponse = try await request(.post, url: APIEndpoints.Notifications.send, body: body)
    }

    // MARK: - Private

    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    private func request<T: Decodable>(_ method: HTTPMethod, url: String, body: (any Encodable)? = nil) async throws -> T {
        let data = try await requestData(method, url: url, body: body)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }

    private func requestData(_ method: HTTPMethod, url: String, body: (any Encodable)? = nil) async throws -> Data {
        guard let url = URL(string: url) else { throw APIError.invalidURL }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let token = try await authService.acquireTokenSilently()
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if let body {
            urlRequest.httpBody = try encoder.encode(body)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            throw APIError.networkError(urlError.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown("Ugyldigt svar fra server")
        }

        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 429:
            throw APIError.rateLimited
        case 500...599:
            throw APIError.serverError(httpResponse.statusCode)
        default:
            throw APIError.unknown("Statuskode: \(httpResponse.statusCode)")
        }
    }
}

// MARK: - Helper types

private struct GraphResponse<T: Codable>: Codable {
    let value: [T]
}

private struct UpdateAbsenceBody: Encodable {
    let endDate: Date?
    let status: AbsenceStatus?
}

private struct ExtendAbsenceBody: Encodable {
    let newEndDate: Date
}

private struct SendNotificationBody: Encodable {
    let absenceId: String
    let groupId: String
}

private struct EmptyResponse: Decodable {}
