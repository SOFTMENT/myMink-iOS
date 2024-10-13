// Copyright © 2023 SOFTMENT. All rights reserved.

import FirebaseAuth
import UIKit

class MyGesture: UITapGestureRecognizer {
    var index: Int = -1
    var id: String = ""
    var value: String?
    var postCell: PostTableViewCell!
    var reelCell: ReelsTableViewCell!
    var currentSelectedImageIndex = 0
    var userModel: UserModel?
    var todoCell : TodoTableViewCell!
    var userListCell : UserTableViewCell!
    var latitude : Double?
    var longitude : Double?
    var ticket : TicketModel?
    var mView : UIView?
    var socialType : SocialMedia?
    
}
