
import SwiftUI
import Supabase

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showEmailForm = false
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            UniversalBackground()
            
            VStack(spacing: 40) {
                VStack(spacing: 24) {
                    Text("MACRO")
                        .font(.system(size: 42, weight: .thin, design: .default))
                        .foregroundColor(.white)
                        .tracking(8)
                        .opacity(0.95)
                    
                    Text("Track. Optimise. Achieve.")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(2)
                }
                .padding(.top, -20)
                
                if !showEmailForm {
                    // Authentication method selection
                    VStack(spacing: 16) {
                        // Apple Sign In
                        Button(action: {
                            Task {
                                await authManager.signInWithApple()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "applelogo")
                                    .frame(width: 20, height: 20)
                                
                                Text("Continue with Apple")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }
                        
                        // Google Sign In
                        Button(action: {
                            Task {
                                await authManager.signInWithGoogle()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image("googlelogoTransparent")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                
                                Text("Continue with Google")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                        
                        // Email option
                        Button(action: {
                            showEmailForm = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .frame(width: 20, height: 20)
                                
                                Text("Continue with Email")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }
                    }
                    
                    // Testing option - will be removed for production
                    Button(action: {
                        Task {
                            await authManager.signInAnonymously()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "eye.slash")
                                .frame(width: 20, height: 20)
                            
                            Text("Continue Anonymously (Testing)")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 1)
                        )
                    }
                } else {
                    // Email authentication form - simple sign up
                    VStack(spacing: 20) {
                        TextField("First Name", text: $firstName)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                        
                        TextField("Last Name", text: $lastName)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                        
                        TextField("Email", text: $email)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                        
                        SecureField("Password", text: $password)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                        
                        Button(action: {
                            Task {
                                await authManager.signUp(with: email, password: password, firstName: firstName, lastName: lastName)
                            }
                        }) {
                            Text("Create Account")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty)
                        
                        Button(action: {
                            showEmailForm = false
                            firstName = ""
                            lastName = ""
                            email = ""
                            password = ""
                        }) {
                            Text("← Back to sign in options")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
    }
    
    
    
}
