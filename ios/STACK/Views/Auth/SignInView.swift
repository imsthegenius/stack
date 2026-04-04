import SwiftUI
import AuthenticationServices

struct SignInView: View {
    let store: StackStore
    @State private var currentNonce: String?
    @State private var errorMessage: String?
    @State private var isProcessing: Bool = false

    var body: some View {
        ZStack {
            StackTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 0) {
                    Text("Keep your\nprogress safe.")
                        .font(StackTypography.display)
                        .foregroundStyle(StackTheme.primaryText)

                    Text("Sign in so your streak survives everything.")
                        .font(StackTypography.callout)
                        .foregroundStyle(StackTheme.primaryText)
                        .padding(.top, 16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, StackSpacing.horizontalPadding)

                Spacer()

                VStack(spacing: 16) {
                    SignInWithAppleButton(.signIn) { request in
                        let nonce = AuthService.randomNonceString()
                        currentNonce = nonce
                        request.requestedScopes = [.email]
                        request.nonce = AuthService.sha256(nonce)
                    } onCompletion: { result in
                        handleSignInResult(result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 52)
                    .clipShape(.rect(cornerRadius: 12))

                    if isProcessing {
                        ProgressView()
                            .tint(StackTheme.secondaryText)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(StackTypography.footnote)
                            .foregroundStyle(StackTheme.secondaryText)
                    }

                    #if DEBUG
                    Button {
                        AuthService.shared.skipSignIn()
                    } label: {
                        Text("Skip (DEBUG only)")
                            .font(StackTypography.caption)
                            .foregroundStyle(StackTheme.secondaryText)
                    }
                    .padding(.top, 8)
                    #endif
                }
                .padding(.horizontal, StackSpacing.horizontalPadding)
                .padding(.bottom, 60)
            }
        }
    }

    private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8),
                  let nonce = currentNonce else {
                errorMessage = "Could not process Apple sign-in."
                return
            }

            // Store Apple authorization code for token revocation on account deletion
            if let codeData = credential.authorizationCode,
               let code = String(data: codeData, encoding: .utf8) {
                AuthService.shared.storeAppleAuthCode(code)
            }

            isProcessing = true
            errorMessage = nil

            Task {
                await AuthService.shared.signInWithApple(idToken: idToken, nonce: nonce)
                isProcessing = false

                if AuthService.shared.isSignedIn {
                    // Load server data first (returning user may have data), then sync local
                    store.loadFromServer()
                    store.syncToServer()
                } else {
                    errorMessage = AuthService.shared.errorMessage ?? "Sign in failed."
                }
            }

        case .failure(let error):
            // User cancelled — ASAuthorizationError.canceled (code 1001)
            if (error as NSError).code != 1001 {
                errorMessage = "Sign in failed. Please try again."
            }
        }
    }
}
