import SwiftUI

struct LoginView: View {
    @State private var viewModel: LoginViewModel

    var onLoginSuccess: (Manager) -> Void

    init(authService: AuthServiceProtocol, onLoginSuccess: @escaping (Manager) -> Void) {
        self._viewModel = State(initialValue: LoginViewModel(authService: authService))
        self.onLoginSuccess = onLoginSuccess
    }

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Logo & tagline
            VStack(spacing: 16) {
                Image(systemName: "person.badge.clock.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.theme.primary)
                    .symbolEffect(.pulse, options: .repeating)

                Text("Fraværsmelder")
                    .font(.largeTitle.bold())

                Text("Registrer og administrer fravær\nfor dit team")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Login buttons
            VStack(spacing: 12) {
                Button {
                    HapticFeedbackManager.impact(.medium)
                    Task { await viewModel.signIn() }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "person.badge.shield.checkmark.fill")
                        Text("Log ind med Microsoft")
                    }
                    .primaryButtonStyle()
                }
                .disabled(viewModel.isLoading)

                if viewModel.showBiometricOption {
                    Button {
                        HapticFeedbackManager.impact(.light)
                        Task { await viewModel.signInWithBiometric() }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "faceid")
                            Text("Log ind med Face ID")
                        }
                        .font(.headline)
                        .foregroundStyle(Color.theme.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.theme.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(viewModel.isLoading)
                }
            }

            if viewModel.isLoading {
                ProgressView("Logger ind...")
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.theme.error)
                    .padding(.horizontal)
            }
        }
        .padding(32)
        .task { await viewModel.checkExistingSession() }
        .onChange(of: viewModel.isAuthenticated) { _, isAuth in
            if isAuth, let manager = viewModel.manager {
                HapticFeedbackManager.notification(.success)
                onLoginSuccess(manager)
            }
        }
    }
}

#Preview {
    LoginView(authService: MockAuthService()) { manager in
        print("Logged in: \(manager.displayName)")
    }
}
