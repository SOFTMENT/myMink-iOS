// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class PushNotificationSender {
    func sendPushNotification(title: String, body: String, topic: String) {
        // MARK: Fetch the PaymentIntent and Customer information from the backend

        // var request = URLRequest(url: backendCheckoutURL)
        // let parameterDictionary = ["amount" : amount, "currency" : currency]
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let url = "https://mymink.com.au/push_notification/topic.php"

        let postData = NSMutableData(
            data: "title=\(title)&message=\(body)&topic=\(topic)"
                .data(using: String.Encoding.utf8)!
        )
        let request = NSMutableURLRequest(
            url: NSURL(string: url)! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data

        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { _, _, _ in
        })
        task.resume()
    }
}
