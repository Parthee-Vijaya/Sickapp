import Foundation
import SwiftData
import Combine

@Observable
final class OfflineSyncManager {
    var isSyncing = false
    var pendingCount = 0
    var lastSyncDate: Date?
    var syncError: String?

    private let apiClient: APIClientProtocol
    private let cacheService: CacheServiceProtocol
    private let networkMonitor: NetworkMonitor

    init(apiClient: APIClientProtocol, cacheService: CacheServiceProtocol, networkMonitor: NetworkMonitor) {
        self.apiClient = apiClient
        self.cacheService = cacheService
        self.networkMonitor = networkMonitor
    }

    // MARK: - Queue offline operations

    func queueAbsenceCreation(_ record: AbsenceRecord) async {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let payload = try encoder.encode(record)
            let operation = PendingOperation(
                id: UUID().uuidString,
                type: .createAbsence,
                payload: payload,
                createdAt: Date()
            )
            try await cacheService.addPendingOperation(operation)
            await updatePendingCount()
        } catch {
            syncError = "Kunne ikke gemme offline: \(error.localizedDescription)"
        }
    }

    func queueAbsenceUpdate(id: String, endDate: Date?, status: AbsenceStatus?) async {
        do {
            let update = OfflineAbsenceUpdate(id: id, endDate: endDate, status: status)
            let payload = try JSONEncoder().encode(update)
            let operation = PendingOperation(
                id: UUID().uuidString,
                type: .updateAbsence,
                payload: payload,
                createdAt: Date()
            )
            try await cacheService.addPendingOperation(operation)
            await updatePendingCount()
        } catch {
            syncError = "Kunne ikke gemme offline: \(error.localizedDescription)"
        }
    }

    func queueAbsenceCancellation(id: String) async {
        do {
            let cancel = OfflineAbsenceCancel(id: id)
            let payload = try JSONEncoder().encode(cancel)
            let operation = PendingOperation(
                id: UUID().uuidString,
                type: .cancelAbsence,
                payload: payload,
                createdAt: Date()
            )
            try await cacheService.addPendingOperation(operation)
            await updatePendingCount()
        } catch {
            syncError = "Kunne ikke gemme offline: \(error.localizedDescription)"
        }
    }

    // MARK: - Sync

    func syncIfNeeded() async {
        guard networkMonitor.isConnected else { return }
        guard !isSyncing else { return }

        let operations: [PendingOperation]
        do {
            operations = try await cacheService.getPendingOperations()
        } catch {
            return
        }

        guard !operations.isEmpty else { return }

        isSyncing = true
        syncError = nil

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        var failedCount = 0

        for operation in operations.sorted(by: { $0.createdAt < $1.createdAt }) {
            do {
                switch operation.type {
                case .createAbsence:
                    let record = try decoder.decode(AbsenceRecord.self, from: operation.payload)
                    _ = try await apiClient.createAbsence(record)

                case .updateAbsence:
                    let update = try decoder.decode(OfflineAbsenceUpdate.self, from: operation.payload)
                    _ = try await apiClient.updateAbsence(id: update.id, endDate: update.endDate, status: update.status)

                case .cancelAbsence:
                    let cancel = try decoder.decode(OfflineAbsenceCancel.self, from: operation.payload)
                    try await apiClient.cancelAbsence(id: cancel.id)
                }

                try await cacheService.removePendingOperation(id: operation.id)
            } catch {
                failedCount += 1
                // Don't remove failed operations - they'll retry next sync
            }
        }

        if failedCount > 0 {
            syncError = "\(failedCount) handling\(failedCount == 1 ? "" : "er") kunne ikke synkroniseres"
        }

        lastSyncDate = Date()
        await updatePendingCount()
        isSyncing = false
    }

    func startAutoSync() {
        // Poll every 30 seconds when online
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                if networkMonitor.isConnected {
                    await syncIfNeeded()
                }
            }
        }
    }

    private func updatePendingCount() async {
        pendingCount = (try? await cacheService.getPendingOperations().count) ?? 0
    }
}

// MARK: - Offline payload types

private struct OfflineAbsenceUpdate: Codable {
    let id: String
    let endDate: Date?
    let status: AbsenceStatus?
}

private struct OfflineAbsenceCancel: Codable {
    let id: String
}
