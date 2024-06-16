// Copyright © 2023 SOFTMENT. All rights reserved.

import Alamofire
import Amplify
import AVFoundation
import BranchSDK
import CallKit
import Combine
import CryptoKit
import Firebase
import FLAnimatedImage
import GoogleSignIn
import MBProgressHUD
import PushKit
import RNCryptor
import SDWebImage
import SwiftUI
import TTGSnackbar
import UIKit
import FirebaseFirestore

// MARK: - UIStoryboard Extensions

extension UIStoryboard {
    class func load(_ storyboard: StoryBoard, _ identifier: Identifier) -> UIViewController {
        UIStoryboard(name: storyboard.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: identifier.rawValue)
    }
}

// MARK: - Int Extensions

extension Int {
    func numberFormator() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? "ERROR"
    }
}

// MARK: - UITextField Extensions

extension UITextField {
    func setLeftView(image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 10, width: 22, height: 22)) // set your Own size
        iconView.image = image
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
        tintColor = .lightGray
    }

    func setRightView(image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 10, width: 22, height: 22)) // set your Own size
        iconView.image = image
        iconView.isUserInteractionEnabled = false
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(iconView)
        iconContainerView.isUserInteractionEnabled = false
        rightView = iconContainerView
        rightView?.isUserInteractionEnabled = false
        rightViewMode = .always
        tintColor = .lightGray
    }

    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }

    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))

        rightView = paddingView
        rightViewMode = .always
    }

    func changePlaceholderColour() {
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(
                red: 225 / 255,
                green: 225 / 255,
                blue: 225 / 255,
                alpha: 1
            )]
        )
    }

    /// set icon of 20x20 with left padding of 8px
    func setLeftIcons(icon: UIImage) {
        let padding = 8
        let size = 20

        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size + padding, height: size))
        let iconView = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)

        leftView = outerView
        leftViewMode = .always
    }

    /// set icon of 20x20 with left padding of 8px
    func setRightIcons(icon: UIImage) {
        let padding = 8
        let size = 12

        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size + padding, height: size))
        let iconView = UIImageView(frame: CGRect(x: -padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)

        rightView = outerView
        rightViewMode = .always
    }
}

// MARK: - Date Extensions

extension Date {
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC)
        else {
            return Date()
        }

        return localDate
    }

    func removeTimeStamp() -> Date? {
        guard let date = Calendar.current
            .date(from: Calendar.current.dateComponents([.year, .month, .day], from: self))
        else {
            return nil
        }
        return date
    }

    func timeAgoSinceDate() -> String {
        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }

        return "a moment ago"
    }
}

// MARK: - UIViewController Extensions

extension UIViewController {
    
  
    // MARK: - Get Coupon Model By Coupon ID
    func getCouponModelBy(couponId: String, completion: @escaping (_ couponModel: CouponModel?) -> Void) {
        let functions = Functions.functions()

        functions.httpsCallable("getCouponModelBy").call(["couponId": couponId]) { result, error in
            if let error = error {
                print("Error calling cloud function: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = result?.data as? [String: Any], let couponData = data["couponModel"] as? [String: Any] {
                let couponModel = CouponModel(data: couponData)
                completion(couponModel)
            } else {
                completion(nil)
            }
        }
    }

    // MARK: - Comment Report
    func reportComment(reason: String, commentID: String, postId: String, completion: @escaping (String) -> Void) {
        let functions = Functions.functions()

        let data: [String: Any] = [
            "reason": reason,
            "commentID": commentID,
            "postId": postId
        ]

        functions.httpsCallable("reportComment").call(data) { result, error in
            if let error = error {
                print("Error calling cloud function: \(error.localizedDescription)")
                completion("An error occurred while submitting your report.")
                return
            }

            if let data = result?.data as? [String: Any], let message = data["message"] as? String {
                completion(message)
            } else {
                completion("An error occurred while submitting your report.")
            }
        }
    }
    
    // MARK: - Comment Report
    func reportPost(reason: String, postID: String, completion: @escaping (String) -> Void) {
        let functions = Functions.functions()

        let data: [String: Any] = [
            "reason": reason,
            "postID": postID
        ]

        functions.httpsCallable("reportPost").call(data) { result, error in
            if let error = error {
                print("Error calling cloud function: \(error.localizedDescription)")
                completion("An error occurred while submitting your report.")
                return
            }

            if let data = result?.data as? [String: Any], let message = data["message"] as? String {
                completion(message)
            } else {
                completion("An error occurred while submitting your report.")
            }
        }
    }
    
    func preparePostScreenshot(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
 


    
    func checkFollow(userID: String, completion: @escaping (Bool, String?) -> Void) {
        let functions = Functions.functions()

        functions.httpsCallable("checkFollow").call(["userID": userID]) { result, error in
            if let error = error as NSError? {
                completion(false, error.localizedDescription)
                return
            }

            if let data = result?.data as? [String: Any],
               let success = data["success"] as? Bool, success {
                let isFollowing = data["isFollowing"] as? Bool ?? false
                completion(isFollowing, nil)
            } else {
                completion(false, "Unknown error")
            }
        }
    }

    func getUserDataByID(uid: String, completion: @escaping (UserModel?, String?) -> Void) {
        FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(uid)
            .getDocument(as: UserModel.self, completion: { result in
                switch result {
                case .success(let userModel):
                    completion(userModel, nil)
                case .failure(let error):
                    completion(nil, error.localizedDescription)
                }
            })
    }

    func checkAuthProvider() -> String {
        
        guard let user = Auth.auth().currentUser else {
            return "No user is currently signed in."
        }

        for userInfo in user.providerData {
            let providerID = userInfo.providerID
            switch providerID {
            case "apple.com":
                return "apple"
            case "google.com":
                return "google"
            case "password":
                return "password"
            case "phone":
                return "phone"
            default:
                return "other"
            }
        }
        return "other"
    }

    func loginWithGoogle(from: String) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in

            if let error = error {
                self.showError(error.localizedDescription)
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            self.authWithFirebase(from: from, credential: credential, phoneNumber: nil, type: "google", displayName: "")
        }
    }

    func getAge(birthDay: Date) -> Int {
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDay, to: now)
        return ageComponents.year!
    }

    func showSnack(messages: String) {
        let snackbar = TTGSnackbar(message: messages, duration: .long)
        snackbar.messageLabel.textAlignment = .center
        snackbar.show()
    }

    func DownloadProgressHUDShow(text: String) -> MBProgressHUD {
        let loading = MBProgressHUD.showAdded(to: view, animated: true)
        loading.mode = .indeterminate
        loading.label.text = text
        loading.label.font = UIFont(name: "times new roman", size: 11)
        return loading
    }

    func DownloadProgressHUDUpdate(loading: MBProgressHUD, text: String) {
        loading.label.text = text
    }

    func ProgressHUDShow(text: String) {
        let loading = MBProgressHUD.showAdded(to: view, animated: true)
        loading.mode = .indeterminate
        loading.label.text = text
        loading.label.font = UIFont(name: "times new roman", size: 11)
    }

    func ProgressHUDHide() {
        MBProgressHUD.hide(for: view, animated: true)
    }


    func addUserData(userData: UserModel) {
        guard let uid = userData.uid, !uid.isEmpty else {
            self.showError("Invalid user ID")
            return
        }

        self.ProgressHUDShow(text: "")
        do {
            try FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(uid).setData(from: userData) { [weak self] error in
                self?.ProgressHUDHide()

                if let error = error {
                    self?.showError(error.localizedDescription)
                } else {
                    self?.getUserData(uid: uid, showProgress: true)
                }
            }
        } catch {
            self.showError(error.localizedDescription)
        }
    }

    func membershipDaysLeft(currentDate: Date, expireDate: Date) -> Int {
        let calendar = Calendar.current
        // Ensure the calculation starts at the beginning of the current day.
        let startOfDay = calendar.startOfDay(for: currentDate)
        // Calculate the difference in days.
        let components = calendar.dateComponents([.day], from: startOfDay, to: expireDate)
        // If the `expireDate` is in the past, return 0 to indicate the membership has expired.
        return max(0, components.day ?? 0)
    }

    func addCommaInLargeNumber(largeNumber: Double) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 10
        return numberFormatter.string(from: NSNumber(floatLiteral: largeNumber))
    }

    /// Retrieves an array of `PostModel` objects for a given user ID.
    /// - Parameters:
    ///   - uid: The user ID to filter posts by.
    ///   - completion: A closure to be executed once the retrieval is complete.
    ///     - posts: An array of `PostModel` objects if the retrieval is successful, `nil` otherwise.
    ///     - error: An error message if an error occurs, `nil` if no errors occur.
    func getPostsBy(uid: String, accountType : AccountType, completion: @escaping ([PostModel]?, String?) -> Void) {
        
        
        var postsQuery = FirebaseStoreManager.db.collection(Collections.POSTS.rawValue)
            .order(by: "postCreateDate", descending: true)
            .whereField(accountType == .USER ? "uid" : "bid", isEqualTo: uid)
        
        if accountType == .USER {
            postsQuery = postsQuery.whereField("isPromoted", isEqualTo: true)
        }
 
        postsQuery.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                // If an error occurs, return with the error message.
                completion(nil, error?.localizedDescription ?? "Unknown error occurred")
                return
            }

            // If there are documents, map them to `PostModel` objects, handling errors in data parsing.
            let postModels = snapshot.documents.compactMap { document -> PostModel? in
                do {
                    return try document.data(as: PostModel.self)
                } catch {
                    print("Error parsing document data: \(error)")
                    return nil
                }
            }

            // Return the array of `PostModel` objects or an empty array if no documents are found.
            completion(postModels, nil)
        }
    }
    
    /// Retrieves an array of `PostModel` objects for a given user ID.
    /// - Parameters:
    ///   - uid: The user ID to filter posts by.
    ///   - completion: A closure to be executed once the retrieval is complete.
    ///     - posts: An array of `PostModel` objects if the retrieval is successful, `nil` otherwise.
    ///     - error: An error message if an error occurs, `nil` if no errors occur.
    func getSavedPosts(userID: String, completion: @escaping ([PostModel]?, Error?) -> Void) {
        let db = Firestore.firestore()
        var postModels = [PostModel]()

        // Step 1: Fetch saved post IDs
        let savedPostsRef = db.collection(Collections.USERS.rawValue).document(userID).collection(Collections.SAVEPOSTS.rawValue).order(by: "date",descending: false)
        savedPostsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(nil, nil)
                return
            }

            // Extract post IDs
            let postIDs = documents.compactMap { document -> String? in
                let data = document.data()
                return data["postId"] as? String
            }
            
            // Step 2: Fetch posts using the post IDs
            let postsRef = db.collection(Collections.POSTS.rawValue)
            let dispatchGroup = DispatchGroup()
            
            for postID in postIDs {
                dispatchGroup.enter()
                postsRef.document(postID).getDocument { (documentSnapshot, error) in
                    if let error = error {
                        print("Error fetching post: \(error)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    if let document = documentSnapshot, document.exists {
                    
                            if let post = try? document.data(as: PostModel.self) {
                                postModels.append(post)
                            }
                       
                    }
                    dispatchGroup.leave()
                }
            }
            
            // Notify completion once all posts are fetched
            dispatchGroup.notify(queue: .main) {
                completion(postModels, nil)
            }
        }
    }

    
    /// Fetches the latest 100 active users from Firestore.
    /// - Parameter completion: A closure that handles the response.
    func getLastest100Users(completion: @escaping (([UserModel]?, String?) -> Void)) {
        self.fetchLatestDocuments(
            collection: "Users",
            orderBy: "registredAt",
            field: "isAccountActive",
            value: true,
            limit: 100,
            completion: completion
        )
    }

    /// Fetches the latest 100 posts of specific types from Firestore.
    /// - Parameter completion: A closure that handles the response.
    func getLatest100Posts(completion: @escaping (([PostModel]?, String?) -> Void)) {
        self.fetchLatestDocuments(
            collection: "Posts",
            orderBy: "postCreateDate",
            field: "postType",
            value: ["video", "image"],
            limit: 100,
            completion: completion
        )
    }

    private func fetchLatestDocuments<PostModel: Decodable>(
        collection: String,
        orderBy: String,
        field: String,
        value: Any,
        limit: Int,
        completion: @escaping (([PostModel]?, String?) -> Void)
    ) {
        var collectionReference = FirebaseStoreManager.db.collection(collection).order(by: orderBy, descending: true)
        if collection == "Posts" {
            collectionReference =  collectionReference.whereField("isPromoted", isEqualTo: true)
        }
       
        // Construct query based on the type of `value`
        let query: Query
        if let arrayValue = value as? [Any] {
            // If value is an array, use 'whereIn'
            query = collectionReference.whereField(field, in: arrayValue)
        } else {
            // If value is a single value, use 'isEqualTo'
            query = collectionReference.whereField(field, isEqualTo: value)
        }

        query.limit(to: limit).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(nil, error?.localizedDescription ?? "Unknown error occurred")
                return
            }

            let documents = snapshot.documents.compactMap { document -> PostModel? in
                do {
                    return try document.data(as: PostModel.self)
                } catch {
                    print("Error parsing document data: \(error)")
                    return nil
                }
            }
            completion(documents, nil)
        }
    }

    func downloadMP4File(from videoURL: URL) {
        if videoURL.pathExtension != "m3u8" {
            let task = URLSession.shared.dataTask(with: videoURL) { data, _, error in
                guard let videoData = data, error == nil else {
                    print("Error downloading video:", error ?? "Unknown error")
                    return
                }

                // Store the downloaded video data to SDWebImage's cache
                SDImageCache.shared.storeImageData(toDisk: videoData, forKey: videoURL.absoluteString)
            }
            task.resume()
        }
    }
    
    
   
    func shareImageAndVideo(postCell: PostTableViewCell?, link: String, postId: String?) {
        guard let url = URL(string: link) else {
            print("Invalid URL")
            return
        }
        
        

        let items: [Any] = [url]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // This ensures compatibility with iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }

        activityViewController.completionWithItemsHandler = { (_, completed: Bool, _: [Any]?, _: Error?) in
            if completed {
                if let postId = postId {
                    if let postCell = postCell {
                        postCell.shareCount.text = "\(Int(postCell.shareCount.text ?? "0")! + 1)"
                        self.addShares(postID: postId)
                    }
                    else  {
                       
                        self.addShares(postID: postId)
                    }
                }
            }
        }

        self.present(activityViewController, animated: true)
    }

    func addShares(postID: String) {
        let id = FirebaseStoreManager.db.collection(Collections.POSTS.rawValue).document(postID).collection(Collections.SHARES.rawValue).document().documentID
        FirebaseStoreManager.db.collection(Collections.POSTS.rawValue).document(postID).collection(Collections.SHARES.rawValue).document(id)
            .setData(["date": Data(), "uid": FirebaseStoreManager.auth.currentUser!.uid])
    }
    func checkCurrentUserLikedPost(postID: String, completion: @escaping (Bool) -> Void) {
        guard let userID = FirebaseStoreManager.auth.currentUser?.uid else {
            // Handle the case where there is no logged in user
            completion(false)
            return
        }

        FirebaseStoreManager.db.collection(Collections.POSTS.rawValue).document(postID).collection(Collections.LIKES.rawValue)
            .document(userID).getDocument { snapshot, error in
                if let error = error {
                    // Log the error or handle it as needed
                    print("Error checking like status: \(error)")
                    completion(false)
                    return
                }

                if let snapshot = snapshot, snapshot.exists {
                    completion(true)
                } else {
                    completion(false)
                }
            }
    }
    
    func addSave(to postID: String,completion : @escaping (_ isSaved : Bool, _ error : String?)->Void) {
        guard let userID = FirebaseStoreManager.auth.currentUser?.uid else {
            completion(false, "User must be logged in to like a post.")
            return
        }

        let savePostModel = SavePostModel()
        savePostModel.date = Date()
        savePostModel.postId = postID

        do {
            try FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(userID).collection(Collections.SAVEPOSTS.rawValue)
                .document(postID).setData(from: savePostModel)
            
            try FirebaseStoreManager.db.collection(Collections.POSTS.rawValue).document(postID).collection(Collections.SAVEPOSTS.rawValue)
                .document(userID).setData(from: savePostModel) { error in
                    if let error  = error {
                        completion(false, error.localizedDescription)
                    }
                    else {
                        completion(true, nil)
                    }
                }
        } catch {
            completion(false, error.localizedDescription)
        }
    }
    
    /// Adds a like to a post by the current user.
    /// - Parameter postID: The ID of the post to like.
    func addLike(to postID: String, completion : @escaping ()->Void) {
        guard let userID = FirebaseStoreManager.auth.currentUser?.uid else {
           
           
            return
        }

        let likeModel = LikeModel()
        likeModel.postID = postID
        likeModel.userID = userID
        likeModel.likeDate = Date()

       
            try? FirebaseStoreManager.db.collection(Collections.POSTS.rawValue).document(postID).collection(Collections.LIKES.rawValue)
                .document(userID).setData(from: likeModel) { error in
                
                    
                    completion()
                    
            }
        
    }
    
    func addSubscribe(_ bid: String, completion : @escaping ()->Void) {
        guard let userID = FirebaseStoreManager.auth.currentUser?.uid else {
           
           
            return
        }

        let subModel = SubscribeModel()
        subModel.userID = userID
        subModel.businessId = bid
        subModel.subscribeDate = Date()

       
            try? FirebaseStoreManager.db.collection(Collections.BUSINESSES.rawValue).document(bid).collection(Collections.SUBSCRIBERS.rawValue)
                .document(userID).setData(from: subModel) { error in
                
                    
                    completion()
                    
            }
        
    }
    
    func deleteSubscribe(bId: String, completion : @escaping ()->Void) {
        let functions = Functions.functions()
        functions.httpsCallable("deleteSubscribe").call(["bid": bId]) { result, error in
          completion()
        }
    }
    
    func checkCurrentUserSubscribe(bId: String, completion: @escaping (Bool) -> Void) {
        guard let userID = FirebaseStoreManager.auth.currentUser?.uid else {
            // Handle the case where there is no logged in user
            completion(false)
            return
        }

        FirebaseStoreManager.db.collection(Collections.BUSINESSES.rawValue).document(bId).collection(Collections.SUBSCRIBERS.rawValue)
            .document(userID).getDocument { snapshot, error in
                if let error = error {
                    // Log the error or handle it as needed
                    print("Error checking like status: \(error)")
                    completion(false)
                    return
                }

                if let snapshot = snapshot, snapshot.exists {
                    completion(true)
                } else {
                    completion(false)
                }
            }
    }
    
    func onPressSaveButton(postId : String, gest : MyGesture){
    
        
        gest.isEnabled = false
       
        checkCurrentUserSavePost(postID: postId) { isSaved in
            SavedManager.shared.toggleSave(for: postId, isSave: !isSaved)
            if isSaved {
                self.deleteSave(postId: postId) {error in 
                    gest.isEnabled = true
                }
            }
            else {
                self.addSave(to: postId) {isSaved,error in 
                    gest.isEnabled = true
                }
            }
            
            
        }
    }
    
    func onPressLikeButton(postId : String, gest : MyGesture){
        
        gest.isEnabled = false
        
        checkCurrentUserLikedPost(postID: postId) { isLiked in
            
            FavoritesManager.shared.toggleFavorite(for: postId, isLiked: !isLiked)
            
            if isLiked {
                self.deleteLike(postId: postId) {
                    gest.isEnabled = true
                }
            }
            else {
                self.addLike(to: postId) {
                    gest.isEnabled = true
                }
            }
        }
    }
    
    func checkCurrentUserSavePost(postID: String, completion: @escaping (Bool) -> Void) {
        guard let userID = FirebaseStoreManager.auth.currentUser?.uid else {
            // Handle the case where there is no logged in user
            completion(false)
            return
        }

        FirebaseStoreManager.db.collection(Collections.POSTS.rawValue).document(postID).collection(Collections.SAVEPOSTS.rawValue)
            .document(userID).getDocument { snapshot, error in
                if let error = error {
                    // Log the error or handle it as needed
                    print("Error checking save status: \(error)")
                    completion(false)
                    return
                }

                if let snapshot = snapshot, snapshot.exists {
                    completion(true)
                } else {
                    completion(false)
                }
            }
    }
    
 

  

    func uploadFilesOnAWS(
        photo: UIImage? = nil,
        videoPath: URL? = nil,
        previousKey : String? = nil,
        folderName: String,
        postType: PostType,
        shouldHideProgress: Bool = false,
        type: String = "jpg",
        completion: @escaping (String?) -> Void
    ) {
        if postType == .IMAGE {
            var loading: MBProgressHUD?
            if !shouldHideProgress {
                loading = self.DownloadProgressHUDShow(text: "Image Uploading : 0.0%")
            }

            let data: Data?
            if type == "jpg" {
                data = photo!.jpegData(compressionQuality: 0.9)
            } else {
                data = photo!.pngData()
            }
         
            let uploadTask = Amplify.Storage.uploadData(
                key: "\(folderName)/\(UUID().uuidString).\(type)",
                data: data!
            )
            Task {
                for await progress in await uploadTask.progress {
                    if !shouldHideProgress {
                        self.DownloadProgressHUDUpdate(
                            loading: loading!,
                            text: "Image Uploading : \(String(format: "%.2f", progress.fractionCompleted * 100))%"
                        )
                    }
                }

                if !shouldHideProgress {
                    DispatchQueue.main.async {
                        self.ProgressHUDHide()
                    }
                }
            }
            Task {
                if let value = try? await uploadTask.value {
                    self.deleteAWSFile(by: previousKey, type: postType)
                    completion(value)
                } else {
                    completion(nil)
                }
            }
        } else if postType == .VIDEO {
            var loading: MBProgressHUD?
            if !shouldHideProgress {
                loading = self.DownloadProgressHUDShow(text: "Video Uploading : 0.0%")
            }
            let uploadTask = Amplify.Storage.uploadFile(key: "\(folderName)/\(UUID().uuidString).mov", local: videoPath!)

            Task {
                for await progress in await uploadTask.progress {
                    if !shouldHideProgress {
                        self.DownloadProgressHUDUpdate(
                            loading: loading!,
                            text: "Video Uploading : \(String(format: "%.2f", progress.fractionCompleted * 100))%"
                        )
                    }
                }
                if !shouldHideProgress {
                    DispatchQueue.main.async {
                        self.ProgressHUDHide()
                    }
                }
            }

            Task {
                if let value = try? await uploadTask.value {
                    if let previousKey = previousKey {
                        self.deleteAWSFile(by: previousKey, type: postType)
                    }
                    completion(value)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    //Get Count
    func deleteAWSFile(by key: String?, type: PostType) {
        if let key = key {
            let functions = Functions.functions()

            functions.httpsCallable("deleteAWSFile").call(["key": key, "type": type.rawValue]) { result, error in
                if error != nil {
                    return
                }
            }
        }
    }
    
    //Get Count
    func getCount(for id: String, countType: String, completion: @escaping (Int?, Error?) -> Void) {
        let functions = Functions.functions()

        functions.httpsCallable("getCount").call(["id": id, "countType": countType]) { result, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let data = result?.data as? [String: Int], let count = data["count"] {
                completion(count, nil)
            } else {
                completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
            }
        }
    }

   
 

    func createDeepLinkForUserProfile(
        userModel: UserModel,
        completion: @escaping (_ url: String?, _ error: Error?) -> Void
    ) {
        let buo = BranchUniversalObject(canonicalIdentifier: userModel.uid ?? "123")
        buo.title = userModel.fullName ?? "Full Name"
        buo.contentDescription = userModel.biography
        buo.imageUrl = "\(Constants.AWS_IMAGE_BASE_URL)/public/\(userModel.profilePic ?? "")"
        buo.contentMetadata.customMetadata["username"] = userModel.username ?? "123"
        buo.contentMetadata.customMetadata["uid"] = userModel.uid ?? "123"
        
        let lp = BranchLinkProperties()
    
        lp.feature = BranchIOFeature.USERPROFILE.rawValue
        lp.addControlParam("$ios_url", withValue: "https://itunes.apple.com/us/app/my-MINK/id6448769013?ls=1&mt=8")
        lp.alias = userModel.username ?? "123"
        buo.getShortUrl(with: lp) { link, error in
            completion(link, error)
        }
    }
    
    
    func createDeepLinkForLivestream(
        userModel: UserModel,
        completion: @escaping (_ url: String?, _ error: Error?) -> Void
    ) {
        let buo = BranchUniversalObject(canonicalIdentifier: "livestream/\(userModel.username ?? "123")")
        buo.title = "Livestreaming"
        buo.contentDescription = "This livestreaming happening on my MINK."
        buo.imageUrl = "\(Constants.AWS_IMAGE_BASE_URL)/public/\(userModel.profilePic ?? "")"
        buo.contentMetadata.customMetadata["uid"] = userModel.uid ?? "123"

        let lp = BranchLinkProperties()
        lp.feature = BranchIOFeature.LIVESTREAM.rawValue
        lp.addControlParam("$ios_url", withValue: "https://itunes.apple.com/us/app/my-MINK/id6448769013?ls=1&mt=8")
        lp.alias = "livestream/\(userModel.username ?? "123")"
        buo.getShortUrl(with: lp) { link, error in
            completion(link, error)
        }
    }
    
    func createDeepLinkForProduct(
        productModel : MarketplaceModel,
        completion: @escaping (_ url: String?, _ error: Error?) -> Void
    ) {
        let buo = BranchUniversalObject(canonicalIdentifier: productModel.id ?? "123")
        buo.title = productModel.title ?? ""
        buo.contentDescription = productModel.about ?? ""
       
        
        
        buo.imageUrl = "\(Constants.AWS_IMAGE_BASE_URL)/fit-in/400x400/public/\(productModel.productImages!.first ?? "")"
        
        buo.contentMetadata.customMetadata["id"] = productModel.id ?? "123"
        buo.contentMetadata.customMetadata["uid"] = productModel.uid ?? "123"

        let lp = BranchLinkProperties()
        
         
        lp.alias = "product/\(productModel.id ?? "123")"
       
    
        lp.feature = BranchIOFeature.PRODUCT.rawValue
        lp.channel = "app"

        lp.addControlParam("$ios_url", withValue: "https://itunes.apple.com/us/app/my-MINK/id6448769013?ls=1&mt=8")
        buo.getShortUrl(with: lp) { link, error in
            completion(link, error)
        }
    }
    
    func createDeepLinkForBusiness(
        businessModel : BusinessModel,
        completion: @escaping (_ url: String?, _ error: Error?) -> Void
    ) {
        let buo = BranchUniversalObject(canonicalIdentifier: businessModel.businessId ?? "123")
        buo.title = businessModel.name ?? ""
        buo.contentDescription = businessModel.aboutBusiness ?? ""
       
        
        
        buo.imageUrl = "\(Constants.AWS_IMAGE_BASE_URL)/fit-in/400x400/public/\(businessModel.profilePicture ?? "")"
        
       
        buo.contentMetadata.customMetadata["bid"] = businessModel.businessId ?? ""

        let lp = BranchLinkProperties()
        
         
        lp.alias = "business/\(businessModel.businessId ?? "123")"
       
    
        lp.feature = BranchIOFeature.BUSINESS.rawValue
        lp.channel = "app"

        lp.addControlParam("$ios_url", withValue: "https://itunes.apple.com/us/app/my-MINK/id6448769013?ls=1&mt=8")
        buo.getShortUrl(with: lp) { link, error in
            completion(link, error)
        }
    }
    

    func createDeepLinkForPost(
        postModel: PostModel,
        completion: @escaping (_ url: String?, _ error: Error?) -> Void
    ) {
        let buo = BranchUniversalObject(canonicalIdentifier: postModel.postID ?? "123")
        buo.title = "my MINK"
        buo.contentDescription = postModel.caption ?? ""
        if postModel.postType == "image" {
        
        
            buo.imageUrl = "\(Constants.AWS_IMAGE_BASE_URL)/fit-in/400x400/public/\(postModel.postImages!.first ?? "")"
        } else if postModel.postType == "video" {
            buo.imageUrl = "\(Constants.AWS_IMAGE_BASE_URL)/fit-in/400x400/public/\(postModel.videoImage ?? "")"
        }
        buo.contentMetadata.customMetadata["postID"] = postModel.postID ?? "123"
        buo.contentMetadata.customMetadata["uid"] = postModel.uid ?? "123"

        let lp = BranchLinkProperties()
        if postModel.postType == "image" {
         
            lp.alias = "image/\(postModel.postID ?? "123")"
        } else if postModel.postType == "video" {
         
            lp.alias = "video/\(postModel.postID ?? "123")"
        }
    
        lp.feature = BranchIOFeature.POST.rawValue
        lp.channel = "app"

        lp.addControlParam("$ios_url", withValue: "https://itunes.apple.com/us/app/my-MINK/id6448769013?ls=1&mt=8")
        buo.getShortUrl(with: lp) { link, error in
            completion(link, error)
        }
    }

 
    func startLiveStream(shouldShowProgress : Bool){
        if shouldShowProgress {
            ProgressHUDShow(text: "")
        }
       
        self.deleteLivestreamingAllAudiences(uid: FirebaseStoreManager.auth.currentUser!.uid)
        generateAgoraToken(friendUid: FirebaseStoreManager.auth.currentUser!.uid) { token in

            FirebaseStoreManager.db.collection(Collections.LIVESTREAMINGS.rawValue).document(FirebaseStoreManager.auth.currentUser!.uid)
                .setData([
                    "token": token,
                    "fullName": UserModel.data!.fullName ?? "",
                    "profilePic": UserModel.data!.profilePic ?? "",
                    "uid": FirebaseStoreManager.auth.currentUser!.uid,
                    "date": Date()
                ]) { _ in
                    if shouldShowProgress {
                        self.ProgressHUDHide()
                    }
                 
                    let liveModel = LiveStreamingModel()
                    liveModel.uid = FirebaseStoreManager.auth.currentUser!.uid
                    liveModel.fullName = UserModel.data!.fullName
                    liveModel.profilePic = UserModel.data!.profilePic
                    liveModel.token = token
                    
                    self.performSegue(withIdentifier: "joinLiveStreamSeg", sender: liveModel)
                }
        }
    }

    func getLivestreamingByUid(uid : String, completion : @escaping (_ liveModel : LiveStreamingModel?)->Void){
        FirebaseStoreManager.db.collection(Collections.LIVESTREAMINGS.rawValue).document(uid).getDocument { snapshot, error in
            if let snapshot = snapshot, !snapshot.exists {
                if let liveModel = try? snapshot.data(as: LiveStreamingModel.self) {
                    completion(liveModel)
                }
                else {
                    completion(nil)
                }
            }
            else {
                completion(nil)
            }
        }
    }
    
    func encodeURL(value: String) -> String? {
        value.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    }

    func readDeepLink(link: String, completion: @escaping (_ uid: String?) -> Void) {
        guard let url =
            URL(
                string: "https://api2.branch.io/v1/url?url=\(link)&branch_key=key_live_mvjwRwp6cXVIpIJM7FOBhjclxsjNUZWv"
            )
        else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, _, error in
            guard error == nil else {
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let uid = data["$canonical_identifier"] as? String, !uid.isEmpty
                {
                    completion(uid)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
                print("Error deserializing JSON: \(error)")
            }
        }

        dataTask.resume()
    }

    func getAllCryptoAssets(
        currency: String,
        completion: @escaping (_ cryptoModel: CryptoModel?, _ error: String?) -> Void
    ) {
        guard let url =
            URL(
                string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(currency)&order=market_cap_desc&per_page=200&page=1&sparkline=false&locale=en"
            )
        else {
            completion(nil, "Invalid URL")
            return
        }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            // Ensure the code is executed on a background thread
            DispatchQueue.global(qos: .userInitiated).async {
                if let error = error {
                    // Call completion handler on the main thread
                    DispatchQueue.main.async {
                        completion(nil, error.localizedDescription)
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(nil, "No data received from the server")
                    }
                    return
                }

                let decoder = JSONDecoder()

                do {
                    let cryptoModel = try decoder.decode(CryptoModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(cryptoModel, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
    
 
    func getHoroscopeModel(completion : @escaping (_ horoscopeModel : HoroscopeModel?, _ error : String?)->Void){
        
        FirebaseStoreManager.db.collection(Collections.HOROSCOPES.rawValue).document("daily").getDocument { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                if let snapshot = snapshot, snapshot.exists {
                    if let horoscopeModel = try? snapshot.data(as: HoroscopeModel.self) {
                        completion(horoscopeModel, nil)
                    }
                }
                else {
                    completion(nil, "Does not exist.")
                }
            }
        }
        
    }
    struct ChatMessage: Codable {
        let role: String
        let content: String
    }

    struct ChatRequest: Codable {
        let model: String
        let messages: [ChatMessage]
    }
    
    func getAllEvents(completion : @escaping (_ events : Array<Event>?, _ error : String?)->Void) {
        FirebaseStoreManager.db.collection(Collections.EVENTS.rawValue).whereField("eventStartDate", isGreaterThan: Date()).whereField("isActive", isEqualTo: true).order(by: "eventCreateDate",descending: true).getDocuments { snapshot, error in
            
            if let error  = error {
                completion(nil, error.localizedDescription)
            }
            else {
                var eventModels = Array<Event>()
                if let snapshot = snapshot, !snapshot.isEmpty {
                
                    for qdr in snapshot.documents {
                        
                        if let eventModel = try? qdr.data(as: Event.self) {
                            eventModels.append(eventModel)
                        }
                    }
                }
                completion(eventModels, nil)
            }
        }
    }
    
    func getAllBusinesses(completion : @escaping (_ businessModel : Array<BusinessModel>?, _ error : String?)->Void) {
        FirebaseStoreManager.db.collection(Collections.BUSINESSES.rawValue).whereField("isActive", isEqualTo: true).order(by: "name").getDocuments { snapshot, error in
            
            if let error  = error {
                completion(nil, error.localizedDescription)
            }
            else {
                var businessModels = Array<BusinessModel>()
                if let snapshot = snapshot, !snapshot.isEmpty {
                
                    for qdr in snapshot.documents {
                        
                        if let businessModel = try? qdr.data(as: BusinessModel.self) {
                            businessModels.append(businessModel)
                        }
                    }
                }
                completion(businessModels, nil)
            }
        }
    }
    
    func getEvent(by eventid : String, completion : @escaping (Event?) -> Void) {
        Firestore.firestore().collection(Collections.EVENTS.rawValue).document(eventid).getDocument { snapshot, error in
            if error == nil {
                if let snap = snapshot {
                    if let event = try? snap.data(as: Event.self) {
                        completion(event)
                    }
                    else {
                        completion(nil)
                    }
                }
                else {
                    completion(nil)
                }
            }
            else {
                completion(nil)
            }
        }
    }
    

    func getResponseFromChatbot(question : String, completion : @escaping (_ chatCompletion : ChatCompletion?, _ error : String?)->Void){
       
        
        
        let request = ChatRequest(model: "gpt-3.5-turbo", messages: [
            ChatMessage(role: "system", content: "You are a helpful assistant."),
            ChatMessage(role: "user", content: question)
        ])

        let apiKey = "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"
        let urlString = "https://api.openai.com/v1/chat/completions"
            guard let url = URL(string: urlString) else { return }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

            do {
                let requestData = try JSONEncoder().encode(request)
                urlRequest.httpBody = requestData
            } catch {
                print()
                completion(nil,"Error encoding request data: \(error)")
                return
            }

            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let data = data, error == nil else {
                   
                    completion(nil,"Network request failed: \(String(describing: error))")
                    return
                }

                do {
                  
                    let chatResponse = try JSONDecoder().decode(ChatCompletion.self, from: data)
                    completion(chatResponse,nil)
                } catch {
                  
                    completion(nil,"Failed to decode response: \(error)")
                }
            }

            task.resume()
    }
    
    func searchSongs(songName: String, completion: @escaping (_ songModel: SongModel?, _ error: String?) -> Void) {
        // MARK: Fetch the PaymentIntent and Customer information from the backend

        let url = "https://my-minkm-usic.vercel.app/search/songs?query=\(songName)&page=1&limit=50"

        let request = NSMutableURLRequest(
            url: NSURL(string: url)! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, _, error in

            guard let data = data,
                  let _ = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else {
                completion(nil, "error")
                return
            }

            let decoder = JSONDecoder()

            do {
                let songModel = try decoder.decode(SongModel.self, from: data)
                completion(songModel, nil)
            } catch {
                completion(nil, error.localizedDescription)
            }
        })
        task.resume()
    }

    func applyStrikethroughEffect(to label: UILabel) {
        guard let text = label.text else { return }
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: attributeString.length))
        
        label.attributedText = attributeString
    }
    
    func removeStrikethroughEffect(from label: UILabel) {
        guard let text = label.text else { return }
        
        // Create a new NSAttributedString without the strikethrough attribute
        let nonStrikethroughAttributeString = NSAttributedString(string: text)
        
        // Set the label's attributedText to remove the strikethrough
        label.attributedText = nonStrikethroughAttributeString
    }
    
    func getMyToDo(uid : String, completion : @escaping (_ todoModels : Array<ToDoModel>?, _ error : String?)->Void){
        FirebaseStoreManager.db.collection(Collections.TASKS.rawValue).order(by: "date").whereField("uid", isEqualTo: uid).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil,error.localizedDescription)
            }
            else {
                var todoModels = Array<ToDoModel>()
                if let snapshot = snapshot {
                    for qdr in snapshot.documents {
                        if let todoModel = try? qdr.data(as: ToDoModel.self) {
                            todoModels.append(todoModel)
                        }
                    }
                }
                completion(todoModels, nil)
            }
        }
    }
    
    func getWeatherInformation(lat : Double, long : Double, completion : @escaping (_ weatherModel : WeatherModel?, _ error : String?)->Void){
        
        self.getCityInformation(lat: lat, long: long) { cityModel, error in
            if let cityModel = cityModel {
                DispatchQueue.main.async {
                    var request = URLRequest(url: URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(long)&units=metric&exclude=minutely,hourly,daily&appid=8476dd87cca140aaba8f099d3e530a99")!,timeoutInterval: Double.infinity)
                    request.httpMethod = "GET"
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data,
                              let _ = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        else {
                            completion(nil, "error - 1")
                            return
                        }

                        let decoder = JSONDecoder()

                      
                        do {
                            let weatherModel = try decoder.decode(WeatherModel.self, from: data)
                            weatherModel.current!.city = cityModel.first?.name
                            completion(weatherModel, nil)
                        } catch {
                            completion(nil, error.localizedDescription)
                        }
                    }

                    task.resume()
                }
                
            }
            else {
                completion(nil, error)
            }
        }
        
        

    }
    
    func getCityInformation(lat : Double, long : Double, completion : @escaping (_ cityModel : CurrentCityModel?, _ error : String?)->Void){
        
        
        var request = URLRequest(url: URL(string: "https://api.openweathermap.org/geo/1.0/reverse?lat=\(lat)&lon=\(long)&limit=1&appid=8476dd87cca140aaba8f099d3e530a99")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
              completion(nil, "error - 2")
            return
          }
            let decoder = JSONDecoder()

          
            do {
                let cityModel = try decoder.decode(CurrentCityModel.self, from: data)
             
                completion(cityModel, nil)
            } catch {
                completion(nil, error.localizedDescription)
            }
        }

        task.resume()
    }

 

    func makeValidURL(urlString: String) -> String {
        let trimmedUrlString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercasedUrlString = trimmedUrlString.lowercased()

        let urlHasHttpPrefix = lowercasedUrlString.hasPrefix("http://")
        let urlHasHttpsPrefix = lowercasedUrlString.hasPrefix("https://")

        return (urlHasHttpPrefix || urlHasHttpsPrefix) ? trimmedUrlString : "http://\(trimmedUrlString)"
    }



    func callCreateSubscriptionFunction(nonce : String, planId : String, completion: @escaping (_ success: Bool?, _ error: String?) -> Void) {
           // Reference to the Cloud Function
           let createSubscriptionFunction = Functions.functions().httpsCallable("createSubscription")

           // Parameters to pass to the Cloud Function
           let requestData: [String: Any] = [
               "paymentMethodNonce": nonce,
               "planId": planId
               // Add any other required parameters
           ]

           // Call the Cloud Function
           createSubscriptionFunction.call(requestData) { result, error in
               if let error = error as NSError? {
                   if error.domain == FunctionsErrorDomain {
                       // Handle Cloud Function error
                       let code = FunctionsErrorCode(rawValue: error.code)
                       let details = error.userInfo[FunctionsErrorDetailsKey]
                     
                       completion(nil,"Create Subscription Function Error: \(code ?? .unknown), details: \(details ?? "")" )
                   }
               } else if let resultData = result?.data as? [String: Any] {
                   // Handle Cloud Function success
                   _ = resultData["message"] as? String ?? ""
                   completion(true, nil)

                   // Now you can handle the success response as needed
               }
           }
       }

    func callCancelSubscriptionFunction(subId : String,completion: @escaping (_ success: Bool?, _ error: String?) -> Void) {
           // Reference to the Cloud Function
           let cancelSubscriptionFunction = Functions.functions().httpsCallable("cancelSubscription")

           // Parameters to pass to the Cloud Function
           let requestData: [String: Any] = [
               "subscriptionId": subId
               // Add any other required parameters
           ]

           // Call the Cloud Function
           cancelSubscriptionFunction.call(requestData) { result, error in
               if let error = error as NSError? {
                   if error.domain == FunctionsErrorDomain {
                       // Handle Cloud Function error
                       let code = FunctionsErrorCode(rawValue: error.code)
                       let details = error.userInfo[FunctionsErrorDetailsKey]
                       completion(nil,"Cancel Subscription Error: \(code ?? .unknown), details: \(details ?? "")" )
                   }
               } else if let resultData = result?.data as? [String: Any] {
                   // Handle Cloud Function success
                   _ = resultData["message"] as? String ?? ""
                   completion(true, nil)

                   // Now you can handle the success response as needed
               }
           }
       }

    
    func hasError(result : HTTPSCallableResult?,error : Error?) -> String? {
        if let error = error as NSError? {
            return error.localizedDescription
        } else if let data = result?.data as? [String: Any] {
            if let error = data["error"] as? String, !error.isEmpty {
                return error
            }
            return nil
        }
        return nil
    }
    
    func algoliaSearch(searchText: String, indexName: SearchIndex,filters : String, completion : @escaping (_ models : Any?)->Void){
        let functions = Functions.functions()
        functions.httpsCallable("searchByAlgolia").call([
            "searchText": searchText,
            "indexName": indexName.rawValue,
            "filters" : filters
        ]) { result, error in
         
            
            if let error = error {
                    print("Error calling function: \(error)")
                    completion(nil)
                    return
                }

            guard let jsonString = result!.data as? String,
                    let jsonData = jsonString.data(using: .utf8) else {
                  print("Data format is incorrect or unable to convert string to Data")
                  completion(nil)
                  return
              }

              do {
                  let decoder = JSONDecoder()
                  decoder.dateDecodingStrategy = .millisecondsSince1970
                  
                  switch indexName {
                  case .POSTS:
                      let posts = try decoder.decode([PostModel].self, from: jsonData)
                      print(posts.count)
                      completion(posts)
                      return
                  case .USERS:
                      let users = try decoder.decode([UserModel].self, from: jsonData)
                      completion(users)
                      return
                  case .EVENTS:
                      let events = try decoder.decode([Event].self, from: jsonData)
                      completion(events)
                      return
                      
                  }
              
                } catch {
                    print("Failed to decode JSON: \(error)")
                    completion(nil)
                }
            
        }
    }
    
    func deleteProduct(productId: String, images: [String], completion : @escaping (_ error : String?)->Void){
        let functions = Functions.functions()
        functions.httpsCallable("deleteProduct").call([
            "id": productId,
            "images": images
        ]) { result, error in
          
            completion(self.hasError(result: result, error: error))
            
        }
    }

    func deletePost(postId: String, completion : @escaping (_ error : String?)->Void) {
        let functions = Functions.functions()
        functions.httpsCallable("deletePostById").call([
            "id": postId
        ]) { result, error in
            completion(self.hasError(result: result, error: error))
        }
    }

    func deleteLike(postId: String, completion : @escaping ()->Void) {
        let functions = Functions.functions()
        functions.httpsCallable("deleteLike").call(["postID": postId]) { result, error in
          completion()
        }
    }
    
    func deleteSave(postId: String, completion : @escaping (_ error : String?)->Void) {
        
        let functions = Functions.functions()
        functions.httpsCallable("deleteSave").call(["postID": postId]) { result, error in
            completion(self.hasError(result: result, error: error))
        }
    }
    
    func deleteDeepLink(endPath: String) {
        let functions = Functions.functions()
        functions.httpsCallable("deleteDeepLink").call(["endPath": endPath]) { result, error in
            // Handle result or error
        }
    }

    func deleteFollow(mainUserId: String, followerUserId: String, completion : @escaping (_ error : String?)->Void) {
        let functions = Functions.functions()
        functions.httpsCallable("deleteFollow").call([
            "mUid": mainUserId,
            "fUid": followerUserId
        ]) { result, error in
            
            FollowingManager.shared.following(uid: followerUserId)
            
            completion(self.hasError(result: result, error: error))
        }
    }

    func deleteLiveRecording(uid: String) {
        let functions = Functions.functions()
        functions.httpsCallable("deleteLiveRecording").call(["uid": uid]) { result, error in
            // Handle result or error
        }
    }

    func deleteLastMessage(uid: String, otherUid: String) {
        let functions = Functions.functions()
        functions.httpsCallable("deleteLastMessage").call([
            "uid": uid,
            "otherUid": otherUid
        ]) { result, error in
            // Handle result or error
        }
    }

    func deleteComment(postId: String, commentId: String, completion : @escaping (_ error : String?)->Void) {
        let functions = Functions.functions()
        functions.httpsCallable("deleteComment").call([
            "postId": postId,
            "commentId": commentId
        ]) { result, error in
            completion(self.hasError(result: result, error: error))
        }
    }

    func deleteCoupon(sCode: String) {
        let functions = Functions.functions()
        functions.httpsCallable("deleteCoupon").call(["sCode": sCode]) { result, error in
            // Handle result or error
        }
    }

    func deleteLivestreamingAllAudiences(uid: String) {
        let functions = Functions.functions()
        functions.httpsCallable("deleteLivestreamingAllAudiences").call(["uid": uid]) { result, error in
            // Handle result or error
        }
    }
    
    func deleteUserAccount(userId: String, username: String, completion : @escaping (_ error : String?)->Void) {
        let functions = Functions.functions()
        functions.httpsCallable("deleteUserAccount").call([
            "userId": userId,
            "username": username
        ]) { result, error in
            completion(self.hasError(result: result, error: error))
        }
    }

    func encryptMessage(message: String, encryptionKey: String) throws -> String {
        let messageData = message.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
        return cipherData.base64EncodedString()
    }

    func decryptMessage(encryptedMessage: String, encryptionKey: String) throws -> String {
        let encryptedData = Data(base64Encoded: encryptedMessage)!
        let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: encryptionKey)
        let decryptedString = String(data: decryptedData, encoding: .utf8)!

        return decryptedString
    }

    func generateEncryptionKey(withPassword password: String) throws -> String {
        let randomData = RNCryptor.randomData(ofLength: 32)
        let cipherData = RNCryptor.encrypt(data: randomData, withPassword: password)
        return cipherData.base64EncodedString()
    }

    func addFollow(mUser: UserModel, fUser: UserModel) {
        let followingRef = FirebaseStoreManager.db.collection(Collections.USERS.rawValue)

        // Creating a follow model for fUser
        let followModelForMUser = self.createFollowModel(from: mUser)
        self.setFollowData(
            userRef: followingRef,
            userId: mUser.uid,
            followUserId: fUser.uid,
            followModel: followModelForMUser
        )

      
    }

    
    func getMarketplaceProductsBy(uid : String, completion : @escaping (_ products : Array<MarketplaceModel>?, _ error : String?)->Void){
        
        FirebaseStoreManager.db.collection(Collections.MARKETPLACE.rawValue).whereField("uid", isEqualTo: uid).order(by: "dateCreated",descending: true).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                var products = Array<MarketplaceModel>()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let productModel = try? qdr.data(as: MarketplaceModel.self) {
                           
                            products.append(productModel)
                        }
                    }
                }
                completion(products, nil)
            }
        }
    }

    func getCountryCode()->String{
        return NSLocale.current.regionCode  ?? "AU"
    }
    
    func getAllMarketplaceProducts(countryCode : String, completion : @escaping (_ products : Array<MarketplaceModel>?, _ error : String?)->Void){
        
        FirebaseStoreManager.db.collection(Collections.MARKETPLACE.rawValue).whereField("isActive", isEqualTo: true).whereField("countryCode", isEqualTo: countryCode).order(by: "dateCreated",descending: true).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                var products = Array<MarketplaceModel>()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let productModel = try? qdr.data(as: MarketplaceModel.self) {
                           
                            products.append(productModel)
                        }
                    }
                }
                completion(products, nil)
            }
        }
        
    }
    
     func increaseProfileView(mUid : String, mFriendUid : String){
    
         FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(mFriendUid).collection(Collections.PROFILEVIEWS.rawValue).document(mUid).setData(["uid" : mUid, "date" : Date()])
        
    }
    // Fetch users based on an array of user IDs
      func fetchUsers(userIds: [String], completion: @escaping ([UserModel]?, Error?) -> Void) {
          // Firestore's limit for the 'in' query is 10
          let chunks = userIds.chunked(into: 10)
          var allUsers: [UserModel] = []
          var allErrors: [Error] = []
          
          let group = DispatchGroup()
          
          for chunk in chunks {
              group.enter()
              fetchChunk(chunk) { users, error in
                  if let users = users {
                      allUsers.append(contentsOf: users)
                  } else if let error = error {
                      allErrors.append(error)
                  }
                  group.leave()
              }
          }
          
          group.notify(queue: .main) {
              if !allErrors.isEmpty {
                  // Handle errors as you see fit. Here we're just passing the first one.
                  completion(nil, allErrors.first)
              } else {
                  completion(allUsers, nil)
              }
          }
      }
      
      // Helper function to fetch a chunk of users
      private func fetchChunk(_ userIds: [String], completion: @escaping ([UserModel]?, Error?) -> Void) {
          FirebaseStoreManager.db.collection(Collections.USERS.rawValue).whereField("uid", in: userIds).getDocuments { snapshot, error in
              if let error = error {
                  completion(nil, error)
                  return
              }
              
              guard let documents = snapshot?.documents else {
                  completion(nil, nil)
                  return
              }
              
              let users: [UserModel] = documents.compactMap { document in
                  let user = try? document.data(as: UserModel.self)
                  return user
              }
              
              completion(users, nil)
          }
      }
    
    func isUserFollowed(currentUserId: String, otherUserId: String, completion: @escaping (Bool) -> Void) {
       
        let followingDocRef = FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(currentUserId).collection(Collections.FOLLOWING.rawValue).document(otherUserId)

        followingDocRef.getDocument { document, error in
            
            
            if let error = error {
                self.showError(error.localizedDescription)
            }
            
            if let document = document, document.exists  {
              
                completion(true)
               
            }
            else {
                completion(false)
            }
            
           
        }
    }
    
    
    func getFollowingByUid(uid : String,completion : @escaping (_ followModels : Array<FollowModel>?)->Void){
        FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(uid).collection(Collections.FOLLOWING.rawValue).order(by: "name").getDocuments { snapshot, error in
            var followModels = Array<FollowModel>()
            if let snapshot = snapshot, !snapshot.isEmpty {
                for qdr in snapshot.documents {
                    if let followModel = try? qdr.data(as: FollowModel.self) {
                        followModels.append(followModel)
                    }
                }
            }
            completion(followModels)
        }
    }
    
    func getFollowersByUid(uid : String,completion : @escaping (_ followModels : Array<FollowModel>?)->Void){
        FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(uid).collection(Collections.FOLLOW.rawValue).order(by: "name").getDocuments { snapshot, error in
            var followModels = Array<FollowModel>()
            if let snapshot = snapshot, !snapshot.isEmpty {
                for qdr in snapshot.documents {
                    if let followModel = try? qdr.data(as: FollowModel.self) {
                        followModels.append(followModel)
                    }
                }
            }
            completion(followModels)
        }
    }
    
    func getLikes(postId : String, completion : @escaping (_ likeModels : Array<LikeModel>?)->Void){
        FirebaseStoreManager.db.collection(Collections.POSTS.rawValue).document(postId).collection(Collections.LIKES.rawValue).getDocuments { snapshot, error in
            var likeModels = Array<LikeModel>()
            if let snapshot = snapshot, !snapshot.isEmpty {
                for qdr in snapshot.documents {
                    if let likeModel = try? qdr.data(as: LikeModel.self) {
                        likeModels.append(likeModel)
                    }
                }
            }
            completion(likeModels)
        }
    }
    
    private func createFollowModel(from user: UserModel) -> FollowModel {
        let followModel = FollowModel()
        followModel.name = user.fullName ?? ""
        followModel.uid = user.uid ?? ""
        return followModel
    }

    private func setFollowData(
        userRef: CollectionReference,
        userId: String?,
        followUserId: String?,
        followModel: FollowModel
    ) {
        guard let userId = userId, !userId.isEmpty,
              let followUserId = followUserId, !followUserId.isEmpty
        else {
            print("Invalid user or follow user ID")
            return
        }

        do {
            try userRef.document(followUserId).collection(Collections.FOLLOW.rawValue).document(userId).setData(from: followModel)
            try userRef.document(userId).collection(Collections.FOLLOWING.rawValue).document(followUserId).setData(from: followModel) { error in
                FollowingManager.shared.following(uid: nil)
            }
        } catch {
            print("Error setting follow data: \(error.localizedDescription)")
        }
    }

    func addPost(postModel: PostModel, completion: @escaping (_ error: String?) -> Void) {
        postModel.isActive = true
    
        
        try? FirebaseStoreManager.db.collection(Collections.POSTS.rawValue).document(postModel.postID ?? "123")
            .setData(from: postModel) { error in
                if let error = error {
                    completion(error.localizedDescription)
                } else {
                    completion(nil)
                }
            }
    }
    func addProduct(marketModel : MarketplaceModel, completion: @escaping (_ error: String?) -> Void) {
        try? FirebaseStoreManager.db.collection(Collections.MARKETPLACE.rawValue).document(marketModel.id ?? "123")
            .setData(from: marketModel) { error in
                if let error = error {
                    completion(error.localizedDescription)
                } else {
                    completion(nil)
                }
            }
    }

    func getPasswordResetTemplate(randomNumber: String) -> String {
        return """
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
                <html xmlns="http://www.w3.org/1999/xhtml">
                <head>
                  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>Verify your login</title>
                  <!--[if mso]><style type="text/css">body, table, td, a { font-family: Arial, Helvetica, sans-serif !important; }</style><![endif]-->
                </head>
                <body style="font-family: Helvetica, Arial, sans-serif; margin: 0px; padding: 0px; background-color: #ffffff;">
                  <table role="presentation"
                    style="width: 100%; border-collapse: collapse; border: 0px; border-spacing: 0px; font-family: Arial, Helvetica, sans-serif; background-color: rgb(255, 255, 255);">
                    <tbody>
                      <tr>
                        <td align="center" style="padding: 1rem 2rem; vertical-align: top; width: 100%;">
                          <table role="presentation" style="max-width: 600px; border-collapse: collapse; border: 0px; border-spacing: 0px; text-align: left;">
                            <tbody>
                              <tr>
                                <td style="padding: 40px 0px 0px;">
                                  <div style="text-align: left;">
                                    <div style="padding-bottom: 20px;"><img src="http://mymink.com.au/logo.png" alt="Logo" style="width: 88px;"></div>
                                  </div>
                                  <div style="background-color: rgb(255, 255, 255);">
                                    <div style="color: rgb(0, 0, 0); text-align: left;">
                                      <h2 style="margin: 1rem 0">Verification code</h2>
                                      <p style="padding-bottom: 16px">Please use the below code for email verification</p>
                                      <p style="padding-bottom: 16px"><strong style="font-size: 130%">\(
                                          randomNumber
                                      )</strong></p>
                                      <p style="padding-bottom: 16px">If you did not request this, you can ignore this email.</p>
                                      <p style="padding-bottom: 16px">Thanks,<br>my MINK Team</p>
                                    </div>
                                  </div>
                                  <div style="padding-top: 20px; color: rgb(153, 153, 153); text-align: center;">
                                    <p style="padding-bottom: 16px">©2023 My Mink Pty Ltd</p>
                                  </div>
                                </td>
                              </tr>
                            </tbody>
                          </table>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </body>
                                                                                                        </html>
        """
    }

    func getEmailVerificationTemplate(randomNumber: String) -> String {
        return """
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml">

        <head>
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Verify your login</title>
          <!--[if mso]><style type="text/css">body, table, td, a { font-family: Arial, Helvetica, sans-serif !important; }</style><![endif]-->
        </head>

        <body style="font-family: Helvetica, Arial, sans-serif; margin: 0px; padding: 0px; background-color: #ffffff;">
          <table role="presentation"
            style="width: 100%; border-collapse: collapse; border: 0px; border-spacing: 0px; font-family: Arial, Helvetica, sans-serif; background-color: rgb(255, 255, 255);">
            <tbody>
              <tr>
                <td align="center" style="padding: 1rem 2rem; vertical-align: top; width: 100%;">
                  <table role="presentation" style="max-width: 600px; border-collapse: collapse; border: 0px; border-spacing: 0px; text-align: left;">
                    <tbody>
                      <tr>
                        <td style="padding: 40px 0px 0px;">
                          <div style="text-align: left;">
                            <div style="padding-bottom: 20px;"><img src="http://mymink.com.au/logo.png" alt="Logo" style="width: 88px;"></div>
                          </div>
                          <div style="background-color: rgb(255, 255, 255);">
                            <div style="color: rgb(0, 0, 0); text-align: left;">
                              <h2 style="margin: 1rem 0">Verification code</h2>
                              <p style="padding-bottom: 16px">Please use the below code for email verification</p>
                              <p style="padding-bottom: 16px"><strong style="font-size: 130%">\(
                                  randomNumber
                              )</strong></p>
                              <p style="padding-bottom: 16px">If you did not request this, you can ignore this email.</p>
                              <p style="padding-bottom: 16px">Thanks,<br>my MINK Team</p>
                            </div>
                          </div>
                          <div style="padding-top: 20px; color: rgb(153, 153, 153); text-align: center;">
                            <p style="padding-bottom: 16px">©2023 My Mink Pty Ltd</p>
                          </div>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </td>
              </tr>
            </tbody>
          </table>
        </body>

        </html>
        """
    }

    

 
    
    func convertDateForEvent(_ date: Date) -> String
        {
        let df = DateFormatter()
        df.dateFormat = "E, MMM dd  yyyy • hh:mm a"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)

    }
    
  

   
    func mergeVideoWithAudio(
        videoURL: URL,
        audioURL: URL,
        success: @escaping ((URL) -> Void),
        failure: @escaping ((Error?) -> Void)
    ) {
        let mixComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction = AVMutableVideoCompositionInstruction()

        let aVideoAsset = AVAsset(url: videoURL)
        let aAudioAsset = AVAsset(url: audioURL)

        if let videoTrack = mixComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ), let audioTrack = mixComposition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) {
            mutableCompositionVideoTrack.append(videoTrack)
            mutableCompositionAudioTrack.append(audioTrack)

            if let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: .video).first,
               let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first
            {
                do {
                    try mutableCompositionVideoTrack.first?.insertTimeRange(
                        CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration),
                        of: aVideoAssetTrack,
                        at: CMTime.zero
                    )
                    try mutableCompositionAudioTrack.first?.insertTimeRange(
                        CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration),
                        of: aAudioAssetTrack,
                        at: CMTime.zero
                    )
                    videoTrack.preferredTransform = aVideoAssetTrack.preferredTransform
                } catch {
                    print(error)
                }

                totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(
                    start: CMTime.zero,
                    duration: aVideoAssetTrack.timeRange.duration
                )
            }
        }

        let mutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mutableVideoComposition.renderSize = CGSize(width: 480, height: 640)

        if let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let outputURL = URL(fileURLWithPath: documentsPath).appendingPathComponent("myminkreel.mov")

            do {
                if FileManager.default.fileExists(atPath: outputURL.path) {
                    try FileManager.default.removeItem(at: outputURL)
                }
            } catch {}

            if let exportSession = AVAssetExportSession(
                asset: mixComposition,
                presetName: AVAssetExportPresetHighestQuality
            ) {
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileType.mov
                exportSession.shouldOptimizeForNetworkUse = true

                // try to export the file and handle the status cases
                exportSession.exportAsynchronously(completionHandler: {
                    DispatchQueue.main.async {
                        switch exportSession.status {
                        case .failed:
                            if let _error = exportSession.error {
                                failure(_error)
                            }

                        case .cancelled:
                            if let _error = exportSession.error {
                                failure(_error)
                            }

                        default:

                            success(outputURL)
                        }
                    }
                })
            } else {
                failure(nil)
            }
        }
    }

    
    func hasMembership()->Bool{
        if let user = UserModel.data, let isActive = user.isAccountActive , isActive {
            return true
        }
        return false
    }
    
    // MARK: - Public Methods

    func getUserData(uid: String, showProgress: Bool) {
        if showProgress {
            self.ProgressHUDShow(text: "")
        }

        FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(uid)
            .getDocument(as: UserModel.self, completion: { result in
                if showProgress {
                    self.ProgressHUDHide()
                }
                switch result {
                case .success(let userModel):

                    UserModel.data = userModel
                    if let isBlocked = userModel.isBlocked, isBlocked {
                    
                        let okAction = UIAlertAction(title: "OK", style: .default) { action in
                            self.logoutPlease()
                         
                        }
                        self.showError("Your account has been blocked. Please contact us on support@mymink.com.au","Blocked", okAction)
                        return
                    }
                    

                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.voipRegistration()
                    }

                    if let username = userModel.username, !username.isEmpty {
                      
                        self.beRootScreen(storyBoardName: .Tabbar, mIdentifier: .TABBARVIEWCONTROLLER)
                        
                    } else {
                        self.beRootScreen(storyBoardName: .AccountSetup, mIdentifier: .COMPLETEPROFILEVIEWCONTROLLER)
                    }

                case .failure(let error):
                    DispatchQueue.main.async {
                        self.beRootScreen(storyBoardName: .AccountSetup, mIdentifier: .ENTRYVIEWCONTROLLER)
                    }
                    self.showError(error.localizedDescription)
                }
            })
    }

    func getViewControllerUsingIdentifier(storyBoardName: StoryBoard, mIdentifier: Identifier) -> UIViewController {
        let storyboard = UIStoryboard(name: storyBoardName.rawValue, bundle: Bundle.main)

        switch mIdentifier {
        case .COMPLETEPROFILEVIEWCONTROLLER:
            return (
                storyboard
                    .instantiateViewController(identifier: mIdentifier.rawValue) as? CompleteProfileViewController
            )!

        case .ENTRYVIEWCONTROLLER:
            return (storyboard.instantiateViewController(identifier: mIdentifier.rawValue) as? EntryViewController)!

        case .MEMBERSHIPVIEWCONTROLLER:
            return (
                storyboard
                    .instantiateViewController(identifier: mIdentifier.rawValue) as? MembershipViewController
            )!

        case .TABBARVIEWCONTROLLER:
            return (storyboard.instantiateViewController(identifier: mIdentifier.rawValue) as? TabbarViewController)!

        case .HOMEVIEWCONTROLLER:
            return (storyboard.instantiateViewController(identifier: mIdentifier.rawValue) as? HomeViewController)!

        case .SEARCHVIEWCONTROLLER:
            return (storyboard.instantiateViewController(identifier: mIdentifier.rawValue) as? SearchViewController)!
        case .CAMERAVIEWCONTROLLER:
            return (storyboard.instantiateViewController(identifier: mIdentifier.rawValue) as? CameraViewController)!
        case .PROFILEVIEWCONTROLLER:
            return (storyboard.instantiateViewController(identifier: mIdentifier.rawValue) as? ProfileViewController)!
        case .REELSVIEWCONTROLLER:
            return (storyboard.instantiateViewController(identifier: mIdentifier.rawValue) as? ReelViewController)!
        case .LIVESTREAMVIEWCONTROLLER:
            return (storyboard.instantiateViewController(identifier: mIdentifier.rawValue) as? LiveViewController)!
        case .NOTIFICATIONCONTROLLER:
            return (
                storyboard
                    .instantiateViewController(identifier: mIdentifier.rawValue) as? NotificationViewController
            )!
        case .ORGANIZERDASHBOARDCONTROLLER:
            return (storyboard.instantiateViewController(identifier: mIdentifier.rawValue) as? OrganisorDashboardViewController)!
        }
    }

    func removeBackground(
        imageData: Data,
        completion: @escaping (_ transparentImageData: Data?, _ error: String?) -> Void
    ) {
        let headers: HTTPHeaders = [
            "x-api-key": ENV.REMOVE_BG_API
        ]

        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(
                    imageData,
                    withName: "image_file",
                    fileName: "car.jpg",
                    mimeType: "image/jpeg"
                )
            },
            to: "https://clipdrop-api.co/remove-background/v1",
            headers: headers
        )
        .responseData(queue: .global()) { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success: do {
                        completion(response.data, nil)
                    }
                case .failure(let error): completion(nil, error.localizedDescription)
                }
            }
        }
    }

    func observeUserStatus() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()
        let userDocRef = db.collection(Collections.USERS.rawValue).document(userId)

        userDocRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                self.logoutPlease()
                return
            }
            if let isBlocked = data["isBlocked"] as? Bool, isBlocked == true {
                self.logoutPlease()
            }
            
        }
    }
    
    func businessPostdeletedErrorFirebase(error : String){
        FirebaseStoreManager.db.collection("BusinessDeletedPost").document().setData(["ERROR" : error, "time" : Date()],merge: true)
    }
    
    func getDeletedPostId(completion : @escaping (_ postId : String?)->Void){
    
        FirebaseStoreManager.db.collection("DeletePost").document("last").addSnapshotListener { snapshot, _ in
            if let snapshot = snapshot, snapshot.exists {
                if let data = snapshot.data() {
                    if let postID = data["postId"] as? String {
                        completion(postID)
                        return
                    }
                   
                }

            }
            completion(nil)
        }

    }
    
    func sendMail(
        to_name: String,
        to_email: String,
        subject: String,
        body: String,
        completion: @escaping (_ error: String) -> Void
    ) {
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        let postData = NSMutableData(
            data: "name=\(to_name)&email=\(to_email)&subject=\(subject)&body=\(body)"
                .data(using: String.Encoding.utf8)!
        )
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://mymink.com.au/mail/sendmail.php")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data

        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { _, _, _ in

            completion("")
        })
        task.resume()
    }

    func sendVOIPNotification(
        deviceToken: String,
        name: String,
        channelName: String,
        token: String,
        callEnd: Bool,
        callUUID: String,
        completion: @escaping (String?, String?) -> Void
    ) {
        // MARK: - Properties

        lazy var functions = Functions.functions()

        functions.httpsCallable("sendVOIPNotification")
            .call([
                "deviceToken": deviceToken,
                "name": name,
                "channelName": channelName,
                "token": token,
                "callEnd": callEnd,
                "callUUID": callUUID
            ] as [String: Any]) { result, error in
                if let error = error {
                    completion(nil, error.localizedDescription)
                } else {
                    if let result = result, let data = result.data as? [String: String] {
                        if let response = data["response"] {
                            if response == "failed" {
                                completion(nil, data["value"])
                            } else {
                                completion(data["value"], nil)
                            }
                        }
                    }
                }
            }
    }

    func callAgoraWebHook(channelName: String, token: String) {
        // MARK: - Properties

        lazy var functions = Functions.functions()

        functions.httpsCallable("startAgoraWebHook")
            .call([
                "channelName": channelName,
                "token": token

            ] as [String: Any]) { result, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("LIVE STREAMING WEB HOOK STARTED")
                }
            }
    }

    func generateAgoraToken(friendUid: String, completion: @escaping (_ token: String) -> Void) {
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        let postData = NSMutableData(data: "userId=\(friendUid)".data(using: String.Encoding.utf8)!)
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://mymink.com.au/VideoCall/RtcTokenGenerate.php")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data

        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, _, _ in

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let token = json["token"] as? String
            else {
                completion("Server not responding")
                return
            }
            completion(token)
        })
        task.resume()
    }

    func beRootScreen(storyBoardName: StoryBoard, mIdentifier: Identifier) {
        guard let window = view.window else {
            view.window?.rootViewController = self.getViewControllerUsingIdentifier(
                storyBoardName: storyBoardName,
                mIdentifier: mIdentifier
            )
            view.window?.makeKeyAndVisible()
            return
        }

        window.rootViewController = self.getViewControllerUsingIdentifier(
            storyBoardName: storyBoardName,
            mIdentifier: mIdentifier
        )
        window.makeKeyAndVisible()
    }

    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }

    func convertSecondstoMinAndSec(totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%02i : %02i", minutes, seconds)
    }

    func convertDateToMonthFormater(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }

    func convertDateAndTimeFormater(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MMM-yyyy hh:mm a"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }

    func convertDateFormaterWithoutDash(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }

    func convertDateFormater(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MMM-yyyy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }

    func convertDateToYearMonthDay(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }

    func convertDateToYearMonth(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMM"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }

    func convertDateToYear(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }

    func convertDateFormaterWithSlash(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }

    func convertDateForHomePage(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEEE, dd MMMM"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }

    func convertDateForVoucher(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "E, MMM dd  yyyy • hh:mm a"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }

    func convertDateForTicket(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "E,MMM dd, yyyy hh:mm a"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }

    func convertDateIntoTime(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "hh:mm a"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return "\(df.string(from: date))"
    }

    func convertDateIntoMonthAndYearForRecurringVoucher(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM • yyyy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return "\(df.string(from: date))"
    }

    func convertDateIntoDayForRecurringVoucher(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEEE"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return "\(df.string(from: date))"
    }

    func convertDateIntoDayDigitForRecurringVoucher(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "d"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return "\(df.string(from: date))"
    }

    func convertDateForShowTicket(_ date: Date, endDate: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "E,dd"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        let s = "\(df.string(from: date))-\(df.string(from: endDate))"
        df.dateFormat = "MMM yyyy"
        return "\(s) \(df.string(from: date))"
    }

    func convertTimeFormater(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "hh:mm a"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }

    func showError(_ message: String,_ title : String = "ERROR", _ okAction : UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }

    func showMessage(title: String, message: String, shouldDismiss: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            if shouldDismiss {
                self.dismiss(animated: true, completion: nil)
            }
        }

        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func dueDateString(for dueDate: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // Remove time components to compare only dates
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let dueDateStartOfDay = calendar.startOfDay(for: dueDate)
        
        if dueDateStartOfDay == today {
            return "Due Today"
        } else if dueDateStartOfDay == tomorrow {
            return "Due Tomorrow"
        } else if dueDateStartOfDay < today {
            return "Overdue"
        } else {
            // For dates beyond tomorrow, calculate the difference and show the date or "In X days"
            let components = calendar.dateComponents([.day], from: today, to: dueDateStartOfDay)
            if let days = components.day, days > 1 {
                return "Due in \(days) days"
            } else {
                // Use DateFormatter for dates far in the future
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return "Due on \(formatter.string(from:  dueDate))"
            }
        }
    }

    func getUser2FAInfo(for userId: String, completion: @escaping (Bool, String?) -> Void) {
        let db = Firestore.firestore()
        db.collection(Collections.USERS.rawValue).document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let is2FAEnabled = document.data()?["is2FAActive"] as? Bool ?? false
                let phoneNumber = document.data()?["phoneNumber2FA"] as? String
                completion(is2FAEnabled, phoneNumber)
            } else {
                completion(false, nil)
            }
        }
    }

    func sendOrResendVerificationCode(
        hint: PhoneMultiFactorInfo,
        resolver: MultiFactorResolver,
        completion: @escaping (_ verificationId: String?, _ error: String?) -> Void
    ) {
        PhoneAuthProvider.provider().verifyPhoneNumber(
            with: hint,
            uiDelegate: nil, // You can provide a UIDelegate for custom UI in the authentication flow
            multiFactorSession: resolver.session
        ) { verificationId, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            } else {
                completion(verificationId, nil)
            }
        }
    }

    func authWithFirebase(
        from: String,
        credential: AuthCredential,
        phoneNumber: String?,
        type: String,
        displayName: String
    ) {
        self.ProgressHUDShow(text: "")

        FirebaseStoreManager.auth.signIn(with: credential) { authResult, error in

            if error != nil {
                self.ProgressHUDHide()
                self.showError(error!.localizedDescription)

            } else {
                self.getUser2FAInfo(for: authResult!.user.uid) { is2FA, phoneNumber in

                    if is2FA, let phoneNumber = phoneNumber {
                        self.sendTwilioVerification(to: phoneNumber) { error in
                            DispatchQueue.main.async {
                                self.ProgressHUDHide()
                                if let error = error {
                                    self.showError(error)
                                } else {
                                    if from == "signIn" {
                                        self.performSegue(
                                            withIdentifier: "signInPhoneVerificationSeg",
                                            sender: phoneNumber
                                        )
                                    } else if from == "signUp" {
                                        self.performSegue(
                                            withIdentifier: "signUpPhoneVerificationSeg",
                                            sender: phoneNumber
                                        )
                                    }
                                }
                            }
                           
                        }
                    } else {
                        self.ProgressHUDHide()
                        let user = authResult!.user
                        let ref = FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(user.uid)
                        ref.getDocument { snapshot, error in
                            if error != nil {
                                self.showError(error!.localizedDescription)
                            } else {
                                if let doc = snapshot {
                                    if doc.exists {
                                        self.getUserData(uid: user.uid, showProgress: true)
                                    } else {
                                        var emailID = ""
                                        let provider = user.providerData
                                        var name = ""
                                        for firUserInfo in provider {
                                            if let email = firUserInfo.email {
                                                emailID = email
                                            }
                                        }

                                        if type == "apple" || type == "phone" {
                                            name = displayName
                                        } else {
                                            name = user.displayName!.capitalized
                                        }

                                        let userData = UserModel()
                                        userData.isBlocked = false
                                        userData.fullName = name
                                        userData.email = emailID
                                        userData.uid = user.uid
                                        userData.registredAt = user.metadata.creationDate ?? Date()
                                        userData.regiType = type
                                        userData.phoneNumber = phoneNumber

                                        self.addUserData(userData: userData)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
   

    func createCustomToken(userId: String, completion: @escaping (_ token: String?, _ error: String?) -> Void) {
        let functions = Functions.functions()
        functions.httpsCallable("createCustomToken").call(["uid": userId]) { result, error in
            if let error = error as NSError? {
                completion(nil, error.localizedDescription)
            } else if let resultData = result?.data as? [String: Any], let token = resultData["token"] as? String {
                completion(token, nil)
            }
        }
    }

    func sendTwilioVerification(to phoneNumber: String, completion: @escaping (_ error: String?) -> Void) {
        let phoneNumber = phoneNumber.addingPercentEncoding(withAllowedCharacters: .alphanumerics)

        let parameters = "To=\(phoneNumber!)&Channel=sms"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(
            url: URL(string: "https://verify.twilio.com/v2/Services/VAcb99097ca8dabc2d7a3c421c51d8c221/Verifications")!,
            timeoutInterval: Double.infinity
        )
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(
            "Basic QUMxOWJiNTc5NWQ5OGYzNTZhMzI5Y2M0ZGYzYmEzNTcyNjoxMDRlZmI3YzAyOTg0ZmNiNzZjNzNkNDE2M2M3YTcyNg==",
            forHTTPHeaderField: "Authorization"
        )

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(error!.localizedDescription)
                return
            }
            do {
                // Attempt to convert the Data object to a JSON object
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(jsonObject)
                    if let status = jsonObject["status"] as? String, status == "pending" {
                        completion(nil)
                    } else {
                        completion("Mobile number is incorrect")
                    }

                } else {
                    completion("Data is not a valid JSON object")
                }
            } catch {
                completion(error.localizedDescription)
            }
        }

        task.resume()
    }

    func verifyTwilioCode(phoneNumber: String, code: String, completion: @escaping (_ error: String?) -> Void) {
        let phoneNumber = phoneNumber.addingPercentEncoding(withAllowedCharacters: .alphanumerics)

        let parameters = "To=\(phoneNumber!)&Code=\(code)"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(
            url: URL(
                string: "https://verify.twilio.com/v2/Services/VAcb99097ca8dabc2d7a3c421c51d8c221/VerificationCheck"
            )!,
            timeoutInterval: Double.infinity
        )
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(
            "Basic QUMxOWJiNTc5NWQ5OGYzNTZhMzI5Y2M0ZGYzYmEzNTcyNjoxMDRlZmI3YzAyOTg0ZmNiNzZjNzNkNDE2M2M3YTcyNg==",
            forHTTPHeaderField: "Authorization"
        )

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(error?.localizedDescription)
                return
            }

            do {
                // Attempt to convert the Data object to a JSON object
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(jsonObject)

                    if let status = jsonObject["status"] as? String, status == "approved" {
                        completion(nil)
                    } else {
                        completion("Verification code is invalid or expired. Please resend new code and try again.")
                    }

                } else {
                    completion("Data is not a valid JSON object")
                }
            } catch {
                completion(error.localizedDescription)
            }
        }

        task.resume()
    }

    func hashPhoneNumber(_ phoneNumber: String) -> String {
        let hashed = SHA256.hash(data: phoneNumber.data(using: .utf8) ?? Data())
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    func generateUniqueCode(using phoneNumber: String) -> String {
        let hash = self.hashPhoneNumber(phoneNumber)
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let desiredLength = 28
        let randomLength = desiredLength - min(desiredLength, hash.count)
        let randomChars = (0 ..< randomLength).compactMap { _ in letters.randomElement() }
        let randomString = String(randomChars)
        return hash.prefix(desiredLength - randomLength) + randomString
    }

    public func logoutPlease() {
       
        try? Auth.auth().signOut()
        
    }
}

// MARK: - UIImageView Extensions

extension UIImageView {
    func makeRounded() {
        // self.layer.borderWidth = 1
        layer.masksToBounds = false
        // self.layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
    }
}

// MARK: - UIView Extensions

extension UIView {
    func addBorder() {
        layer.borderWidth = 0.8
        layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
    }

    public var safeAreaFrame: CGFloat {
        if #available(iOS 13.0, *) {
            if let window = UIApplication.shared.currentUIWindow() {
                return window.safeAreaInsets.bottom
            }
        } else {
            let window = UIApplication.shared.keyWindow
            return window!.safeAreaInsets.bottom
        }
        return 34
    }

    func smoothShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 5
        //        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.8)
        layer.shadowPath = UIBezierPath(rect: CGRect(
            x: 0,
            y: bounds.maxY - layer.shadowRadius,
            width: bounds.width,
            height: layer.shadowRadius
        )).cgPath
    }

    func installBlurEffect(isTop: Bool) {
        backgroundColor = UIColor.clear
        var blurFrame = bounds

        if isTop {
            var statusBarHeight: CGFloat = 0.0
            if #available(iOS 13.0, *) {
                if let window = UIApplication.shared.currentUIWindow() {
                    statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                }
            } else {
                statusBarHeight = UIApplication.shared.statusBarFrame.height
            }

            blurFrame.size.height += statusBarHeight
            blurFrame.origin.y -= statusBarHeight
        } else {
            if let window = UIApplication.shared.currentUIWindow() {
                let bottomPadding = window.safeAreaInsets.bottom
                blurFrame.size.height += bottomPadding
            }

            //  blurFrame.origin.y += bottomPadding
        }
        let blur = UIBlurEffect(style: .light)
        let visualeffect = UIVisualEffectView(effect: blur)
        visualeffect.backgroundColor = UIColor(red: 244 / 255, green: 244 / 255, blue: 244 / 255, alpha: 0.7)
        visualeffect.frame = blurFrame
        addSubview(visualeffect)
    }

    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = .zero
        layer.shadowRadius = 2
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath

        layer.mask = mask
    }
}

public extension Date {
    func setTime(hour: Int, min: Int, timeZoneAbbrev: String = "UTC") -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: self)

        components.timeZone = TimeZone(abbreviation: timeZoneAbbrev)
        components.hour = hour
        components.minute = min

        return cal.date(from: components)
    }
}

extension Double {
    func truncate(places: Int) -> Double {
        Double(floor(pow(10.0, Double(places)) * self) / pow(10.0, Double(places)))
    }
}

public extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }

        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
    }
}

extension Double {
    func formatUsingAbbrevation() -> String {
        let numFormatter = NumberFormatter()

        typealias Abbrevation = (threshold: Double, divisor: Double, suffix: String)
        let abbreviations: [Abbrevation] = [
            (0, 1, ""),
            (1000.0, 1000.0, "K"),
            (100_000.0, 1_000_000.0, "M"),
            (100_000_000.0, 1_000_000_000.0, "B")
        ]
        // you can add more !

        let startValue = Double(abs(self))
        let abbreviation: Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if startValue < tmpAbbreviation.threshold {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        }()

        let value = Double(self) / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1

        return numFormatter.string(from: NSNumber(value: value))!
    }
}

extension Int {
    func formatUsingAbbrevation() -> String {
        let numFormatter = NumberFormatter()

        typealias Abbrevation = (threshold: Double, divisor: Double, suffix: String)
        let abbreviations: [Abbrevation] = [
            (0, 1, ""),
            (1000.0, 1000.0, "K"),
            (100_000.0, 1_000_000.0, "M"),
            (100_000_000.0, 1_000_000_000.0, "B")
        ]
        // you can add more !

        let startValue = Double(abs(self))
        let abbreviation: Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if startValue < tmpAbbreviation.threshold {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        }()

        let value = Double(self) / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1

        return numFormatter.string(from: NSNumber(value: value))!
    }
}

// MARK: - AppDelegate + PKPushRegistryDelegate, CXProviderDelegate

extension AppDelegate: PKPushRegistryDelegate, CXProviderDelegate {
    func providerDidReset(_: CXProvider) {
        //
    }

    /// Handle updated push credentials
    func pushRegistry(_: PKPushRegistry, didUpdate credentials: PKPushCredentials, for _: PKPushType) {
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        if let user = FirebaseStoreManager.auth.currentUser {
            FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(user.uid)
                .setData(["deviceToken": deviceToken], merge: true)
            
            self.getBusinessesBy(user.uid) { businessModel, error in
                if let businessModel = businessModel {
                    FirebaseStoreManager.db.collection(Collections.BUSINESSES.rawValue).document(businessModel.businessId ?? "123")
                        .setData(["deviceToken":deviceToken], merge: true)
                }
            }
        }
    }

    func pushRegistry(_: PKPushRegistry, didInvalidatePushTokenFor _: PKPushType) {
        print("pushRegistry:didInvalidatePushTokenForType:")
    }

    func pushRegistry(
        _: PKPushRegistry,
        didReceiveIncomingPushWith payload: PKPushPayload,
        for _: PKPushType,
        completion _: @escaping () -> Void
    ) {
        self.handlePushPayload(payload)
    }

    func handlePushPayload(_ payload: PKPushPayload) {
        if FirebaseStoreManager.auth.currentUser != nil {
            let myPayload = payload.dictionaryPayload

            if let hasCallEndedByLocal = myPayload["callEnd"] as? Bool, hasCallEndedByLocal {
                let callUUID = UUID(uuidString: myPayload["callUUID"] as! String)!
                let endCallAction = CXEndCallAction(call: callUUID)
                let transaction = CXTransaction(action: endCallAction)
                let callController = CXCallController()
                callController.request(transaction) { error in
                    if let error = error {
                        print("Error ending call: \(error)")
                    }
                }
            } else {
                Constants.token = myPayload["token"] as! String
                Constants.channelName = myPayload["channelName"] as! String
                Constants.callUUID = UUID(uuidString: myPayload["callUUID"] as! String)!
                CallManager.shared.reportIncomingCall(
                    id: Constants.callUUID,
                    channelName: myPayload["channelName"] as! String,
                    token: myPayload["token"] as! String,
                    handle: myPayload["messageFrom"] as! String,
                    appDeletegate: self
                )
            }
        }
    }

    
    func provider(_: CXProvider, perform action: CXAnswerCallAction) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let rootVC = UIStoryboard(name: StoryBoard.Tabbar.rawValue, bundle: nil)
                .instantiateViewController(withIdentifier: "videoVC") as! VideoCallViewController

            rootVC.channelName = Constants.channelName
            rootVC.token = Constants.token
            let window = UIApplication
                .shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }

            rootVC.view.frame = window!.bounds

            UIView.transition(with: window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window!.rootViewController = rootVC
            }, completion: nil)
            action.fulfill()
        }
    }

    func provider(_: CXProvider, perform action: CXEndCallAction) {
        let callDeniedModel = CallDeniedModel()
        callDeniedModel.date = Date()
        callDeniedModel.callDenied = true

        try? FirebaseStoreManager.db.collection("CallDenied").document(action.callUUID.uuidString)
            .setData(from: callDeniedModel, merge: true)
        action.fulfill()
    }

    func provider(_: CXProvider, perform _: CXStartCallAction) {}
}

extension UIImage {
    func addToCenter(of superView: UIView, width: CGFloat = 150, height: CGFloat = 60) {
        let overlayImageView = UIImageView(image: self)
        overlayImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayImageView.contentMode = .scaleAspectFit
        superView.addSubview(overlayImageView)

        let centerXConst = NSLayoutConstraint(
            item: overlayImageView,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: superView,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        )
        let width = NSLayoutConstraint(
            item: overlayImageView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: width
        )
        let height = NSLayoutConstraint(
            item: overlayImageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: height
        )
        let centerYConst = NSLayoutConstraint(
            item: overlayImageView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: superView,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        )

        NSLayoutConstraint.activate([width, height, centerXConst, centerYConst])
    }
}

extension UIImageView {
    func setImage(
        imageKey: String?,
        placeholder: String,
        width: Int = 300,
        height: Int = 300,
        shouldShowAnimationPlaceholder: Bool = false
    ) {
        guard let imageKey = imageKey else {
            return
        }
        let original = "\(Constants.AWS_IMAGE_BASE_URL)/fit-in/\(width)x\(height)/public/\(imageKey)"
        
        let actualImageURL = URL(string: original)
   
        let mImage = SDAnimatedImageView()
        let placeholder1 = SDAnimatedImage(named: "imageload.gif")
        mImage.image = placeholder1

        if shouldShowAnimationPlaceholder {
            sd_setImage(with: actualImageURL, placeholderImage: placeholder1) { _, error, _, _ in
                if let error = error {
                       print("Error loading image: \(error.localizedDescription)")
                }
                mImage.stopAnimating()
            }
        } else {
            sd_setImage(with: actualImageURL, placeholderImage: UIImage(named: placeholder))
        }
    }
}
 
// Extension to help with partitioning arrays
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: self.count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, self.count)])
        }
    }
}


extension Array where Element: Equatable {
    mutating func remove(_ element: Element) {
        if let index = self.firstIndex(of: element) {
            self.remove(at: index)
        }
    }
}

extension NSObject {
    
    func getBusinessesBy(_ uid : String, completion : @escaping (_ businessModel : BusinessModel?, _ error : String?)->Void) {
        FirebaseStoreManager.db.collection(Collections.BUSINESSES.rawValue).whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            
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
        
        FirebaseStoreManager.db.collection(Collections.BUSINESSES.rawValue).document(businessId).getDocument { snapshot, error in
            
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
