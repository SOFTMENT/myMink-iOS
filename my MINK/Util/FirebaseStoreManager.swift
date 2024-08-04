// Copyright © 2023 SOFTMENT. All rights reserved.

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FirebaseStoreManager {
    static let db = Firestore.firestore()
    static let auth = Auth.auth()
    static let messaging = Messaging.messaging()
    
}
