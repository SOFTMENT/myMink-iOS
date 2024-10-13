// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit
import FirebaseFunctions

class PushNotificationSender {
    private lazy var functions = Functions.functions()
    func sendPushNotification(title: String, body: String, topic: String) {
       
               // Prepare the data to send to the Cloud Function
               let data: [String: Any] = [
                   "deviceToken": topic,
                   "title": title,
                   "body": body
               ]

               // Call the 'sendNotification' Cloud Function
               functions.httpsCallable("sendNotification").call(data) { result, error in
                   if let error = error as NSError? {
                       // Handle any errors here
                       print("Error calling Cloud Function: \(error.localizedDescription)")
                       return
                   }

                   // Handle the result from the Cloud Function
                   if let resultData = result?.data as? [String: Any] {
                       if let success = resultData["success"] as? Bool, success {
                           print("Notification sent successfully!")
                       } else {
                           print("Failed to send notification.")
                       }
                   }
               }
          
    }
}
