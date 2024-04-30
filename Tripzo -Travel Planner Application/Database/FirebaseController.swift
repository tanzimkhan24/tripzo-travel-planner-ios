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

class FirebaseController: NSObject, DatabaseProtocol {
    
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
    
    func getCurrentUser(completion: @escaping (Users?) -> Void) {
        guard let uid = authController.currentUser?.uid else {
            completion(nil)
            return
        }
        usersRef?.document(uid).getDocument { (document, error) in
            if let document = document, document.exists, let user = try? document.data(as: Users.self) {
                completion(user)
            } else {
                completion(nil)
            }
        }
    }

    
    func addAuthListener() {
        authListenerHandle = authController.addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            self.currentUser = user
            if let user = user {
                self.checkAndHandleNewUser(user)
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
            guard let self = self else { return }
            if let error = error {
                self.listeners.invoke { listener in
                    listener.onError(error)
                }
                return
            }
            if let user = authResult?.user {
                self.currentUser = user
                self.checkAndHandleNewUser(user)
                listeners.invoke {listener in
                    listener.onSignIn()
                }
            }
        }
    }
    
    func createAccountWithEmail(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        authController.createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                completion(false, error)
                return
            }
            if let user = authResult?.user {
                self.currentUser = user
                listeners.invoke {listener in
                    listener.onAccountCreated()
                }
                completion(true, nil)
            } else {
                completion(false, NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]))
            }
        }
    }
    
    func signInWithGoogle(presentingViewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.listeners.invoke { listener in
                    listener.onError(error)
                }
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                self.listeners.invoke { listener in
                    listener.onError(NSError(domain: "FirebaseController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign-In data not retrieved."]))
                }
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            self.firebaseSignIn(credential, isNewUserCheckNeeded: true)
        }
    }

    func signInWithFacebook(from viewController: UIViewController) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: viewController) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.listeners.invoke { listener in
                    listener.onError(error)
                }
                return
            }
            guard let result = result, !result.isCancelled, let token = AccessToken.current?.tokenString else {
                self.listeners.invoke { listener in
                    listener.onError(NSError(domain: "FirebaseController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Facebook Sign-In cancelled or failed to retrieve access token."]))
                }
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            self.firebaseSignIn(credential, isNewUserCheckNeeded: true)
        }
    }

    func firebaseSignIn(_ credential: AuthCredential, isNewUserCheckNeeded: Bool) {
        authController.signIn(with: credential) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                self.listeners.invoke { listener in
                    listener.onError(error)
                }
                return
            }
            guard let user = authResult?.user else {
                self.listeners.invoke { listener in
                    listener.onError(NSError(domain: "FirebaseController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase sign-in did not return a user."]))
                }
                return
            }
            self.currentUser = user
            if isNewUserCheckNeeded {
                self.checkAndHandleNewUser(user)
            } else {
                self.listeners.invoke { listener in
                    listener.onSignIn()
                }
            }
        }
    }

    func checkAndHandleNewUser(_ user: FirebaseAuth.User) {
        usersRef?.document(user.uid).getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                self.listeners.invoke { listener in
                    listener.onSignIn()
                }
            } else {
                let newUser = Users()  // Assuming we create a User object to pass to listeners
                newUser.email = user.email
                newUser.name = user.displayName
                self.listeners.invoke { listener in
                    listener.onNewUser(userDetails: newUser)
                }
            }
        }
    }

    func addUser(name: String?, phoneNumber: String?, country: String?, gender: String?, email: String?) {
        guard let uid = authController.currentUser?.uid else {
            print("No user UID found")
            return
        }
        let newUser = Users()
        newUser.name = name
        newUser.email = email
        newUser.phoneNumber = phoneNumber
        newUser.country = country
        newUser.gender = gender

        do {
            try usersRef?.document(uid).setData(from: newUser) { error in
                if let error = error {
                    print("Error adding user to Firestore: \(error.localizedDescription)")
                } else {
                    print("User added to Firestore with UID: \(uid)")
                }
            }
        } catch let error {
            print("Error serializing user: \(error.localizedDescription)")
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

}
