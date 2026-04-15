import Foundation

@Observable
final class AbsenceHistoryViewModel {
    var records: [AbsenceRecord] = []
    var isLoading = false
    var errorMessage: String?
    var selectedTypeFilter: AbsenceType?
    var showCalendarView = false

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    var filteredRecords: [AbsenceRecord] {
        guard let typeFilter = selectedTypeFilter else { return records }
        return records.filter { $0.absenceType == typeFilter }
    }

    var recordsByMonth: [(key: String, value: [AbsenceRecord])] {
        let grouped = Dictionary(grouping: filteredRecords) { record in
            record.startDate.formatted(as: .dayMonth)
        }
        return grouped.sorted { $0.value.first!.startDate > $1.value.first!.startDate }
    }

    var recordsByDate: [Date: [AbsenceRecord]] {
        Dictionary(grouping: filteredRecords) { $0.startDate.startOfDay }
    }

    func loadData(managerId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            records = try await apiClient.getAbsences(managerId: managerId, status: nil, type: nil)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func endAbsence(id: String, endDate: Date) async {
        do {
            let updated = try await apiClient.updateAbsence(id: id, endDate: endDate, status: .ended)
            if let index = records.firstIndex(where: { $0.id == id }) {
                records[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancelAbsence(id: String) async {
        do {
            try await apiClient.cancelAbsence(id: id)
            if let index = records.firstIndex(where: { $0.id == id }) {
                records[index].status = .cancelled
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
