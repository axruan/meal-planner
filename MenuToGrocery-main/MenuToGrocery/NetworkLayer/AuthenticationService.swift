//
//AuthenticationService.swift
//
//
///This class is responsible to auenticate user to Firestore.
///The cotent is referenced from this tutoria: https://www.kodeco.com/11609977-getting-started-with-cloud-firestore-and-swiftui#toc-anchor-017
///
///For this project, no authentication is used.  Anonymouse user is used as the test user. 
///
import Foundation
import Firebase

class AuthenticationService: ObservableObject {
    
    @Published var user: User?
    private var authenticationStateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        addListeners()
    }
    
    static func signIn() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously()
        }
    }
    
    private func addListeners() {
        if let handle = authenticationStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
        authenticationStateHandler = Auth.auth()
            .addStateDidChangeListener { _, user in
                self.user = user
            }
    }
}

