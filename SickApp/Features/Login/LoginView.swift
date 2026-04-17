import SwiftUI

struct LoginView: View {
    @State private var viewModel: LoginViewModel

    var onLoginSuccess: (Manager) -> Void

    init(authService: AuthServiceProtocol, onLoginSuccess: @escaping (Manager) -> Void) {
        self._viewModel = State(initialValue: LoginViewModel(authService: authService))
        self.onLoginSuccess = onLoginSuccess
    }

    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // Animated MeshGradient background (warm Kalundborg tones)
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [animateGradient ? 0.6 : 0.4, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    Color.theme.darkSurface, Color.theme.gradientNavy, Color.theme.darkSurfaceLight,
                    Color.theme.gradientTerracotta.opacity(0.7), Color.theme.darkSurface, Color.theme.gradientTeal.opacity(0.4),
                    Color.theme.gradientCoral.opacity(0.5), Color.theme.gradientTerracotta.opacity(0.6), Color.theme.darkSurfaceLight
                ]
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }

            VStack(spacing: 40) {
                Spacer()

                // Logo & tagline
                VStack(spacing: 16) {
                    Image(systemName: "person.badge.clock.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                        .symbolEffect(.breathe, options: .repeating)
                        .shadow(color: Color.theme.primary.opacity(0.4), radius: 20)

                    Text("Fraværsmelder")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text("Registrer og administrer fravær\nfor dit team")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Login card
                VStack(spacing: 16) {
                    Button {
                        HapticFeedbackManager.impact(.medium)
                        Task { await viewModel.signIn() }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "person.badge.key.fill")
                            Text("Login med EntraID")
                        }
                        .primaryButtonStyle()
                    }
                    .disabled(viewModel.isLoading)

                    Button {
                        HapticFeedbackManager.impact(.medium)
                        Task { await viewModel.signIn() }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "building.2.fill")
                            Text("FKA Login")
                        }
                        .secondaryButtonStyle()
                    }
                    .disabled(viewModel.isLoading)

                    if viewModel.isLoading {
                        ProgressView("Logger ind...")
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(Color.theme.error)
                    }
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.2), radius: 24, y: 12)
            }
            .padding(32)
        }
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
