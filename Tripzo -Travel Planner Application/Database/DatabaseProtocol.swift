//
//  DatabaseProtocol.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 24/4/2024.
//

import Foundation
import UIKit

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case all
}

protocol DatabaseListener: AnyObject {

    var listenerType: ListenerType {get set}
    func onSignIn()
    func onAccountCreated()
    func onError(_ error: Error)
    func onSignOut()
    func onNewUser(userDetails: Users?)
}

protocol DatabaseProtocol: AnyObject {
    
    func getCurrentUser(completion: @escaping (Users?) -> Void)
    
    func addUser(name: String?, phoneNumber: String?, country: String?, gender: String?, email: String?)
    func signInWithGoogle(presentingViewController: UIViewController)
    func signInWithFacebook(from viewController: UIViewController)
    func signInWithEmail(email: String, password: String)
    func isUserSignedIn() -> Bool
    func signOut()
    func createAccountWithEmail(email: String, password: String, completion: @escaping (Bool, Error?) -> Void)
    func addAuthListener()
    func removeAuthListener()
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
