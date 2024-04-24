//
//  FirebaseController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 24/4/2024.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices
import CryptoKit



class FirebaseController: NSObject, DatabaseProtocol, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var usersRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    var authListenerHandle: AuthStateDidChangeListenerHandle?
    var currentNonce: String?
    var user: Users
    
    override init() {
        
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        usersRef = database.collection("users")
        user = Users()
        super.init()
        addAuthListener()
        
    }
    
    func addAuthListener() {
            authController.addStateDidChangeListener { [weak self] (auth, user) in
                guard let self = self else { return }
                self.currentUser = user
                if user != nil {
                    self.listeners.invoke { listener in
                        listener.onSignIn()
                    }
                }
            }
        }
    
    func removeAuthListener() {
        if let handle = authListenerHandle {
            authController.removeStateDidChangeListener(handle)
        }
    }
        
    func signInWithEmail(email: String, password: String) {
            authController.signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let error = error {
                    self?.listeners.invoke { listener in
                        listener.onError(error)
                    }
                    return
                }
                self?.currentUser = authResult?.user
                self?.listeners.invoke { listener in
                    listener.onSignIn()
                }
            }
    }
        
    // In FirebaseController
    func createAccountWithEmail(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        authController.createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                completion(false, error)
                return
            }

            if let user = authResult?.user {
                self.currentUser = user
                completion(true, nil)  // Notify the caller of success
            } else {
                completion(false, NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]))
            }
        }
    }
    
    func signInWithApple() {
            let nonce = randomNonceString()
            currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }

    func sha256(_ input: String) -> String {
            let inputData = Data(input.utf8)
            let hashedData = SHA256.hash(data: inputData)
            return hashedData.compactMap { String(format: "%02x", $0) }.joined()
        }
        
    func randomNonceString(length: Int = 32) -> String {
            precondition(length > 0)
            let charset: Array<Character> =
                Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
            var result = ""
            var remainingLength = length
            
            while remainingLength > 0 {
                let randoms: [UInt8] = (0..<16).map { _ in
                    var random: UInt8 = 0
                    let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                    if errorCode != errSecSuccess {
                        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                    }
                    return random
                }
                
                randoms.forEach { random in
                    if remainingLength == 0 {
                        return
                    }
                    
                    if random < charset.count {
                        result.append(charset[Int(random)])
                        remainingLength -= 1
                    }
                }
            }
            
            return result
        }
        
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce, let appleIDToken = appleIDCredential.identityToken, let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    // Handle error.
                    return
                }
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
                Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                    if let error = error {
                        self?.listeners.invoke { listener in
                            listener.onError(error)
                        }
                        return
                    }
                    self?.currentUser = authResult?.user
                    self?.listeners.invoke { listener in
                        listener.onSignIn()
                    }
                }
            }
        }
        
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            listeners.invoke { listener in
                listener.onError(error)
            }
        }
        
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return UIApplication.shared.windows.first { $0.isKeyWindow }!
    }

    func signInWithGoogle(presentingViewController: UIViewController) {
            
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            let config = GIDConfiguration(clientID: clientID)
            
            GIDSignIn.sharedInstance.configuration = config
            
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
                guard error == nil else {
                    self?.listeners.invoke { listener in
                        listener.onError(error!)
                    }
                    return
                }
                
                guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                    self?.listeners.invoke { listener in
                        listener.onError(NSError(domain: "FirebaseController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign-In data not retrieved."]))
                    }
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                
                self?.authController.signIn(with: credential) { [weak self] authResult, error in
                    if let error = error {
                        self?.listeners.invoke { listener in
                            listener.onError(error)
                        }
                        return
                    }
                    
                    self?.currentUser = authResult?.user
                    self?.listeners.invoke { listener in
                        listener.onSignIn()
                    }
                }
            }
        }
    
    func signInWithFacebook(from viewController: UIViewController) {
            let loginManager = LoginManager()
            
            loginManager.logIn(permissions: ["public_profile", "email"], from: viewController) { [weak self] (result, error) in
                if let error = error {
                    // Handle the error appropriately
                    print("Error: \(error.localizedDescription)")
                    self?.listeners.invoke { listener in
                        listener.onError(error)
                    }
                    return
                }
                
                guard let result = result, !result.isCancelled else {
                    print("User cancelled the Facebook login.")
                    return
                }
                
                guard let accessToken = AccessToken.current?.tokenString else {
                    print("Failed to get access token")
                    let tokenError = NSError(domain: "FirebaseController", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to get Facebook access token."])
                    self?.listeners.invoke { listener in
                        listener.onError(tokenError)
                    }
                    return
                }
                
                // Use the access token to create a Firebase credential and sign in
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
                self?.authController.signIn(with: credential) { [weak self] (authResult, error) in
                    if let error = error {
                        // Handle the error appropriately
                        print("Firebase auth error: \(error.localizedDescription)")
                        self?.listeners.invoke { listener in
                            listener.onError(error)
                        }
                        return
                    }
                    // Inform listeners about the successful login
                    self?.listeners.invoke { listener in
                        listener.onSignIn()
                    }
                }
            }
        }
        
    func addListener(listener: DatabaseListener) {
            listeners.addDelegate(listener)
    }
        
    func removeListener(listener: DatabaseListener) {
            listeners.removeDelegate(listener)
    }
        
    func cleanup() {
            // Implement any necessary cleanup.
    }
    
    func signOut() {
            // Sign out from Firebase
            do {
                try authController.signOut()
            } catch let signOutError as NSError {
                print("Error signing out from Firebase: %@", signOutError)
            }
            
            // Sign out from Google
            GIDSignIn.sharedInstance.signOut()

            // Sign out from Facebook
            let loginManager = LoginManager()
            loginManager.logOut()
            
            // Notify listeners about the sign out event
            listeners.invoke { listener in
                listener.onSignOut()
            }
        }
    
    func isUserSignedIn() -> Bool {
        return currentUser != nil
    }
    
    func addUser(name: String, phoneNumber: String, country: String, gender: String, email: String) {
        
        let newUser = Users()
        newUser.name = name
        newUser.email = email
        newUser.phoneNumber = phoneNumber
        newUser.country = country
        newUser.gender = gender
        
        guard let uid = authController.currentUser?.uid else {
            print("No user uid found")
            return
        }
        
        do {
                // Here, usersRef should be defined as a CollectionReference
                try usersRef?.document(uid).setData(from: newUser, completion: { error in
                    if let error = error {
                        print("Error adding user to Firestore: \(error.localizedDescription)")
                    } else {
                        print("User added to Firestore with document ID: \(uid)")
                    }
                })
            } catch let error {
                print("Error serializing user: \(error.localizedDescription)")
            }
    }
    
    
        

}


