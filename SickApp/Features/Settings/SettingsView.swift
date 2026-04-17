import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showLogoutConfirmation = false
    var onLogout: () -> Void

    init(authService: AuthServiceProtocol, apiClient: APIClientProtocol, cacheService: CacheServiceProtocol, onLogout: @escaping () -> Void) {
        self._viewModel = State(initialValue: SettingsViewModel(authService: authService, apiClient: apiClient, cacheService: cacheService))
        self.onLogout = onLogout
    }

    var body: some View {
        NavigationStack {
            List {
                // Account
                Section {
                    if let manager = viewModel.manager {
                        HStack(spacing: 14) {
                            AvatarView(name: manager.displayName, photoData: manager.photoData, size: 56)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(manager.displayName)
                                    .font(.headline)
                                if let title = manager.jobTitle {
                                    Text(title)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                if let mail = manager.mail {
                                    Text(mail)
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Konto")
                }

                // Notifications
                Section("Notifikationer") {
                    if !viewModel.teamGroups.isEmpty {
                        Picker("Standard teamgruppe", selection: $viewModel.defaultGroupId) {
                            Text("Ingen").tag(String?.none)
                            ForEach(viewModel.teamGroups) { group in
                                Text(group.displayName).tag(Optional(group.id))
                            }
                        }
                    }
                    Toggle("Modtag email-kopi", isOn: $viewModel.receiveEmailCopy)
                }

                // Security
                Section("Sikkerhed") {
                    Toggle("Face ID / Touch ID", isOn: $viewModel.useBiometric)
                }

                // Appearance
                Section("Visning") {
                    Picker("Udseende", selection: $viewModel.appearance) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.rawValue).tag(appearance)
                        }
                    }
                    Toggle("Kompakt visning", isOn: $viewModel.compactMode)
                }

                // Data
                Section("Data") {
                    Button {
                        Task { await viewModel.clearCache() }
                    } label: {
                        Label("Ryd cache", systemImage: "trash")
                    }
                }

                // About
                Section("Om") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundStyle(.secondary)
                    }
                    Link(destination: URL(string: "https://organisation.dk/privacy")!) {
                        Label("Privatlivspolitik", systemImage: "hand.raised")
                    }
                    Link(destination: URL(string: "mailto:support@organisation.dk")!) {
                        Label("Support", systemImage: "envelope")
                    }
                }

                // Logout
                Section {
                    Button(role: .destructive) {
                        showLogoutConfirmation = true
                    } label: {
                        Label("Log ud", systemImage: "rectangle.portrait.and.arrow.right")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Indstillinger")
            .task { await viewModel.loadSettings() }
            .confirmationDialog("Log ud", isPresented: $showLogoutConfirmation) {
                Button("Log ud", role: .destructive) {
                    Task {
                        try? await viewModel.signOut()
                        onLogout()
                    }
                }
            } message: {
                Text("Er du sikker på, at du vil logge ud?")
            }
        }
    }
}

#Preview {
    SettingsView(
        authService: MockAuthService(),
        apiClient: MockAPIClient(),
        cacheService: MockCacheService(),
        onLogout: {}
    )
}
