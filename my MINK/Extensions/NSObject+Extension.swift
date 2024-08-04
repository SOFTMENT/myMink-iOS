//
//  NSObject+Extension.swift
//  my MINK
//
//  Created by Vijay Rathore on 15/07/24.
//

import Foundation

extension NSObject {
    
    func getBusinessesBy(_ uid : String, completion : @escaping (_ businessModel : BusinessModel?, _ error : String?)->Void) {
        FirebaseStoreManager.db.collection(Collections.businesses.rawValue).whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            
            if let error  = error {
                completion(nil, error.localizedDescription)
            }
            else {
              
                if let snapshot = snapshot, !snapshot.isEmpty {
                
                    
                        
                    if let businessModel = try? snapshot.documents.first!.data(as: BusinessModel.self) {
                        completion(businessModel, nil)
                        return
                        }
                    else {
                        completion(nil,"Failed to decode")
                    }
                   
                }
                completion(nil,"Empty")
            }
        }
    }
    
    func getBusinesses(by businessId : String, completion : @escaping (_ businessModel : BusinessModel?, _ error : String?)->Void) {
        
        FirebaseStoreManager.db.collection(Collections.businesses.rawValue).document(businessId).getDocument { snapshot, error in
            
            if let error  = error {
                completion(nil, error.localizedDescription)
            }
            else {
              
                if let snapshot = snapshot, snapshot.exists {
                
                    
                        
                    if let businessModel = try? snapshot.data(as: BusinessModel.self) {
                        completion(businessModel, nil)
                        return
                        }
                    else {
                        completion(nil,"Failed to decode")
                    }
                   
                }
                completion(nil,"Empty")
            }
        }
    }
}



