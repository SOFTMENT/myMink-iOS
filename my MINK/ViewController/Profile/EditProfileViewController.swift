// Copyright © 2023 SOFTMENT. All rights reserved.

import CropViewController
import Firebase
import UIKit

// MARK: - EditProfileDelegate

protocol EditProfileDelegate {
    func refreshUI()
}

// MARK: - EditProfileViewController

class EditProfileViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var address: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeight: NSLayoutConstraint!
    let selectGenderPicker = UIPickerView()
    @IBOutlet var backView: UIView!
    @IBOutlet var mProfile: UIImageView!
    @IBOutlet var uploadProfileBtn: UIButton!
    @IBOutlet var website: UITextField!
    @IBOutlet var bioGraphyTV: UITextView!
    @IBOutlet var fullName: UITextField!
    @IBOutlet var changePasswordStack: UIStackView!
    @IBOutlet var continueBtn: UIButton!
    var isImageSelected = false
    var delegate: EditProfileDelegate?
    @IBOutlet var oldPassword: UITextField!
    @IBOutlet var newPassword: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    @IBOutlet var changePasswordBtn: UIButton!
    var places: [Place] = []

    @IBOutlet weak var twitterCircle: CircleView!
    @IBOutlet weak var instagramCircle: CircleView!
    @IBOutlet weak var tiktokCircle: CircleView!
    @IBOutlet weak var facebookCircle: CircleView!
    @IBOutlet weak var youtubeCircle: CircleView!
    @IBOutlet weak var rumCircle: CircleView!
    @IBOutlet weak var twitchCircle: CircleView!
    @IBOutlet weak var redditCircle: CircleView!
    @IBOutlet weak var tumblrCircle: CircleView!
    @IBOutlet weak var discordCircle: CircleView!
    @IBOutlet weak var telegramCircle: CircleView!
    @IBOutlet weak var mastodonCircle: CircleView!
    @IBOutlet weak var pintrestCircle: CircleView!
    @IBOutlet weak var etsyCircle: CircleView!
    @IBOutlet weak var linkedinCircle: CircleView!
    @IBOutlet weak var whatsAppCircle: CircleView!

    @IBOutlet weak var addSocialMediaBtn: UIButton!
    @IBOutlet weak var twitterView: UIView!
    @IBOutlet weak var twitterNumber: UILabel!
    @IBOutlet weak var instagramView: UIView!
    @IBOutlet weak var instagramNumber: UILabel!
    @IBOutlet weak var tiktokView: UIView!
    @IBOutlet weak var tikTokNumber: UILabel!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var facebookNumber: UILabel!
    @IBOutlet weak var youtubeView: UIView!
    @IBOutlet weak var youtubeNumber: UILabel!
    @IBOutlet weak var rumView: UIView!
    @IBOutlet weak var rumNumber: UILabel!
    @IBOutlet weak var twitchView: UIView!
    @IBOutlet weak var twitchNumber: UILabel!
    @IBOutlet weak var redditView: UIView!
    @IBOutlet weak var redditNumber: UILabel!
    @IBOutlet weak var tumblr: UIView!
    @IBOutlet weak var tumblrNumer: UILabel!
    @IBOutlet weak var discordView: UIView!
    @IBOutlet weak var discordNumber: UILabel!
    @IBOutlet weak var telegramView: UIView!
    @IBOutlet weak var telegramNumber: UILabel!
    @IBOutlet weak var mastodonView: UIView!
    @IBOutlet weak var mastodonNumber: UILabel!
    @IBOutlet weak var pintrestView: UIView!
    @IBOutlet weak var pintrestNumber: UILabel!
    @IBOutlet weak var etsyView: UIView!
    @IBOutlet weak var etsyNumber: UILabel!
    @IBOutlet weak var linkedinView: UIView!
    @IBOutlet weak var linkedinNumber: UILabel!
    @IBOutlet weak var whatsAppView: UIView!
    @IBOutlet weak var whatsAppNumber: UILabel!

    var socialMediaModels = Array<SocialMediaModel>()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = UserModel.data, let _ = delegate else {
            DispatchQueue.main.async {
                self.logoutPlease()
            }
            return
        }
        
        setupUI(user: user)
        configureTextFields()
        configureGestures()
        configurePasswordFields()
    }

    private func setupUI(user: UserModel) {
        if let profilePath = user.profilePic, !profilePath.isEmpty {
            self.mProfile.setImage(imageKey: profilePath, placeholder: "profile-placeholder", width: 400, height: 400)
        }

        self.fullName.text = user.fullName ?? ""
        self.address.text = user.location ?? ""
        self.website.text = user.website ?? ""
        self.bioGraphyTV.text = user.biography ?? ""

        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
        self.tableView.contentInsetAdjustmentBehavior = .never

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44

        self.mProfile.layer.cornerRadius = 8
        self.uploadProfileBtn.layer.cornerRadius = 6

        self.bioGraphyTV.layer.cornerRadius = 8
        self.bioGraphyTV.layer.borderWidth = 1
        self.bioGraphyTV.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
        self.bioGraphyTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        self.continueBtn.layer.cornerRadius = 8
        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backViewClicked)))

        self.changePasswordBtn.layer.cornerRadius = 8

        if checkAuthProvider() != "password" {
            self.changePasswordStack.isHidden = true
        }

        addSocialMediaBtn.layer.cornerRadius = 8
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hidekeyboard)))
    }

    private func configureTextFields() {
        self.address.delegate = self
        self.address.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        self.website.delegate = self
        self.fullName.delegate = self
        self.newPassword.delegate = self
        self.oldPassword.delegate = self
        self.confirmPassword.delegate = self
    }

    private func configureGestures() {
        configureSocialMediaGestures()
    }

    private func configureSocialMediaGestures() {
        let socialMediaViews: [(UIView?, SocialMedia)] = [
            (twitterView, .twitter), (instagramView, .instagram), (tiktokView, .tiktok),
            (facebookView, .facebook), (youtubeView, .youtube), (rumView, .rumble),
            (twitchView, .twitch), (redditView, .reddit), (tumblr, .tumblr),
            (discordView, .discord), (telegramView, .telegram), (mastodonView, .mastodon),
            (pintrestView, .pinterest), (etsyView, .etsy), (linkedinView, .linkedin),
            (whatsAppView, .whatsapp)
        ]

        for (view, socialMedia) in socialMediaViews {
            view?.isUserInteractionEnabled = true
            let gesture = MyGesture(target: self, action: #selector(socialViewClicked))
            gesture.socialType = socialMedia
            view?.addGestureRecognizer(gesture)
        }
    }


    private func configurePasswordFields() {
        setupPasswordField(passwordField: self.newPassword, action: #selector(self.passwordEyeClicked))
        setupPasswordField(passwordField: self.oldPassword, action: #selector(self.oldpasswordEyeClicked))
        setupPasswordField(passwordField: self.confirmPassword, action: #selector(self.confirmpasswordEyeClicked))
    }

    private func setupPasswordField(passwordField: UITextField, action: Selector) {
        passwordField.rightViewMode = .always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
        imageView.image = UIImage(named: "hide")
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(imageView)
        passwordField.rightView = iconContainerView
        passwordField.rightView?.isUserInteractionEnabled = true
        passwordField.rightView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSocialMediaSeg", let vc = segue.destination as? EditSocialMediaViewContoller, let socialMediaModel = sender as? SocialMediaModel {
            vc.socialMediaModel = socialMediaModel
        }
    }

    @IBAction func addSocialMediaClicked(_ sender: Any) {
        performSegue(withIdentifier: "addSocialMediaSeg", sender: nil)
    }

    @objc func socialViewClicked(value: MyGesture) {
        let models = socialMediaModels.filter { $0.name == value.socialType!.rawValue }
        if models.count > 1 {
            self.showAlertForEdit(models: models)
        } else {
            performSegue(withIdentifier: "editSocialMediaSeg", sender: models.first!)
        }
    }

    func showAlertForEdit(models: [SocialMediaModel]) {
        let alert = UIAlertController(title: nil, message: "Select Account", preferredStyle: .actionSheet)
        for model in models {
            alert.addAction(UIAlertAction(title: model.link ?? "NIL", style: .default, handler: { _ in
                self.performSegue(withIdentifier: "editSocialMediaSeg", sender: model)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllSocialMedia(uid: FirebaseStoreManager.auth.currentUser!.uid) { socialMediaModels in
            self.hideAllSocialMedia()
            if let socialMediaModels = socialMediaModels {
                self.socialMediaModels = socialMediaModels
                for model in socialMediaModels {
                    self.updateSocialMediaView(for: model)
                }
            }
        }
    }

    private func updateSocialMediaView(for model: SocialMediaModel) {
        switch model.name {
        case SocialMedia.twitter.rawValue:
            updateSocialMediaView(twitterView, numberLabel: twitterNumber, circleView: twitterCircle)
        case SocialMedia.instagram.rawValue:
            updateSocialMediaView(instagramView, numberLabel: instagramNumber, circleView: instagramCircle)
        case SocialMedia.tiktok.rawValue:
            updateSocialMediaView(tiktokView, numberLabel: tikTokNumber, circleView: tiktokCircle)
        case SocialMedia.facebook.rawValue:
            updateSocialMediaView(facebookView, numberLabel: facebookNumber, circleView: facebookCircle)
        case SocialMedia.youtube.rawValue:
            updateSocialMediaView(youtubeView, numberLabel: youtubeNumber, circleView: youtubeCircle)
        case SocialMedia.rumble.rawValue:
            updateSocialMediaView(rumView, numberLabel: rumNumber, circleView: rumCircle)
        case SocialMedia.twitch.rawValue:
            updateSocialMediaView(twitchView, numberLabel: twitchNumber, circleView: twitchCircle)
        case SocialMedia.reddit.rawValue:
            updateSocialMediaView(redditView, numberLabel: redditNumber, circleView: redditCircle)
        case SocialMedia.tumblr.rawValue:
            updateSocialMediaView(tumblr, numberLabel: tumblrNumer, circleView: tumblrCircle)
        case SocialMedia.discord.rawValue:
            updateSocialMediaView(discordView, numberLabel: discordNumber, circleView: discordCircle)
        case SocialMedia.telegram.rawValue:
            updateSocialMediaView(telegramView, numberLabel: telegramNumber, circleView: telegramCircle)
        case SocialMedia.mastodon.rawValue:
            updateSocialMediaView(mastodonView, numberLabel: mastodonNumber, circleView: mastodonCircle)
        case SocialMedia.pinterest.rawValue:
            updateSocialMediaView(pintrestView, numberLabel: pintrestNumber, circleView: pintrestCircle)
        case SocialMedia.etsy.rawValue:
            updateSocialMediaView(etsyView, numberLabel: etsyNumber, circleView: etsyCircle)
        case SocialMedia.linkedin.rawValue:
            updateSocialMediaView(linkedinView, numberLabel: linkedinNumber, circleView: linkedinCircle)
        case SocialMedia.whatsapp.rawValue:
            updateSocialMediaView(whatsAppView, numberLabel: whatsAppNumber, circleView: whatsAppCircle)
        default:
            break
        }
    }

    private func updateSocialMediaView(_ view: UIView, numberLabel: UILabel, circleView: CircleView) {
        view.isHidden = false
        numberLabel.text = String((Int(numberLabel.text ?? "0") ?? 0) + 1)
        if (Int(numberLabel.text ?? "0") ?? 0) > 1 {
            circleView.isHidden = false
        }
    }

    func hideAllSocialMedia() {
        let socialMediaViews: [(UIView?, UILabel?, UIView?)] = [
            (twitterView, twitterNumber, twitterCircle), (instagramView, instagramNumber, instagramCircle),
            (tiktokView, tikTokNumber, tiktokCircle), (facebookView, facebookNumber, facebookCircle),
            (youtubeView, youtubeNumber, youtubeCircle), (rumView, rumNumber, rumCircle),
            (twitchView, twitchNumber, twitchCircle), (redditView, redditNumber, redditCircle),
            (tumblr, tumblrNumer, tumblrCircle), (discordView, discordNumber, discordCircle),
            (telegramView, telegramNumber, telegramCircle), (mastodonView, mastodonNumber, mastodonCircle),
            (pintrestView, pintrestNumber, pintrestCircle), (etsyView, etsyNumber, etsyCircle),
            (linkedinView, linkedinNumber, linkedinCircle), (whatsAppView, whatsAppNumber, whatsAppCircle)
        ]

        for (view, numberLabel, circleView) in socialMediaViews {
            view?.isHidden = true
            numberLabel?.text = "0"
            circleView?.isHidden = true
        }
    }


    @IBAction func changePasswordClicked(_ sender: Any) {
        guard
            let sOldPassword = self.oldPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let sNewPassword = self.newPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let sConfirmPassword = self.confirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !sOldPassword.isEmpty, !sNewPassword.isEmpty, !sConfirmPassword.isEmpty
        else {
            self.showSnack(messages: "Please fill in all password fields")
            return
        }

        guard let userModel = UserModel.data else { return }

        do {
            let originalPassword = try self.decryptMessage(
                encryptedMessage: userModel.encryptPassword ?? "",
                encryptionKey: userModel.encryptKey ?? ""
            )

            guard originalPassword == sOldPassword else {
                self.showSnack(messages: "Current password is incorrect")
                return
            }

            guard sNewPassword == sConfirmPassword else {
                self.showSnack(messages: "New and confirm password mismatch")
                return
            }

            guard sOldPassword != sNewPassword else {
                self.showError("Current password and new password must be different.")
                return
            }

            updatePassword(originalPassword: originalPassword, newPassword: sNewPassword)
        } catch {
            self.showError("Error decrypting password.")
        }
    }

    private func updatePassword(originalPassword: String, newPassword: String) {
        guard let user = Auth.auth().currentUser, let userModel = UserModel.data else { return }

        let credential = EmailAuthProvider.credential(withEmail: userModel.email!, password: originalPassword)
        self.ProgressHUDShow(text: "")
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                self.ProgressHUDHide()
                self.showError(error.localizedDescription)
            } else {
                Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error.localizedDescription)
                    } else {
                        self.updateEncryptedPassword(newPassword: newPassword, user: user)
                    }
                }
            }
        }
    }

    private func updateEncryptedPassword(newPassword: String, user: User) {
        guard let userModel = UserModel.data else { return }

        do {
            userModel.encryptPassword = try self.encryptMessage(
                message: newPassword,
                encryptionKey: userModel.encryptKey!
            )
            Firestore.firestore().collection(Collections.users.rawValue).document(user.uid).setData(
                ["encryptPassword": userModel.encryptPassword!], merge: true
            ) { error in
                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
                    self.clearPasswordFields()
                    self.showSnack(messages: "Password has been changed")
                }
            }
        } catch {
            self.showError("Error encrypting password.")
        }
    }

    private func clearPasswordFields() {
        self.newPassword.text = ""
        self.confirmPassword.text = ""
        self.oldPassword.text = ""
    }

    @objc func passwordEyeClicked() {
        togglePasswordVisibility(for: self.newPassword)
    }

    @objc func oldpasswordEyeClicked() {
        togglePasswordVisibility(for: self.oldPassword)
    }

    @objc func confirmpasswordEyeClicked() {
        togglePasswordVisibility(for: self.confirmPassword)
    }

    private func togglePasswordVisibility(for passwordField: UITextField) {
        passwordField.isSecureTextEntry.toggle()
        let imageName = passwordField.isSecureTextEntry ? "hide" : "view"
        let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
        imageView.image = UIImage(named: imageName)
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(imageView)
        passwordField.rightView = iconContainerView
        passwordField.rightView?.isUserInteractionEnabled = true
        passwordField.rightView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(passwordEyeClicked)))
    }

    @objc func textFieldDidChange(textField: UITextField) {
        guard let query = textField.text, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.places.removeAll()
            self.tableView.reloadData()
            return
        }

        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
                self.places = places
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    @objc func hidekeyboard() {
        view.endEditing(true)
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }

    @IBAction func continueBtnClicked(_: Any) {
        guard
            let sWeb = self.website.text, !sWeb.isEmpty,
            let sBio = self.bioGraphyTV.text, !sBio.isEmpty,
            let sFullname = self.fullName.text, !sFullname.isEmpty,
            let sAddress = self.address.text, !sAddress.isEmpty
        else {
            showSnack(messages: "Please fill in all fields")
            return
        }

        let userModel = UserModel.data
        userModel!.biography = sBio
        userModel!.website = sWeb
        userModel!.location = sAddress
        userModel!.fullName = sFullname

        if self.isImageSelected {
            uploadFilesOnAWS(photo: self.mProfile.image!, previousKey: userModel!.profilePic, folderName: "ProfilePictures", postType: .image) { downloadURL in
                userModel!.profilePic = downloadURL
                self.updateProfile(userModel: userModel!)
            }
        } else {
            self.updateProfile(userModel: userModel!)
        }
    }

    private func updateProfile(userModel: UserModel) {
        self.ProgressHUDShow(text: "")
        try? FirebaseStoreManager.db.collection(Collections.users.rawValue).document(FirebaseStoreManager.auth.currentUser!.uid).setData(from: userModel, merge: true) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            } else {
                self.delegate!.refreshUI()
                self.showSnack(messages: "Profile Updated")
            }
        }
    }

    @objc func locationCellClicked(myGesture: MyGesture) {
        self.tableView.isHidden = true
        view.endEditing(true)

        let place = self.places[myGesture.index]
        self.address.text = place.name ?? ""

        GooglePlacesManager.shared.resolveLocation(for: place) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                print(error)
            }
        }
    }

    func updateTableViewHeight() {
        self.tableViewHeight.constant = self.tableView.contentSize.height
        self.tableView.layoutIfNeeded()
    }

    @IBAction func uploadProfileClick(_: Any) {
        let alert = UIAlertController(title: "Upload Profile Picture", message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Using Camera", style: .default) { _ in
            self.showImagePicker(sourceType: .camera)
        }
        let action2 = UIAlertAction(title: "From Photo Library", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary)
        }
        let action3 = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        present(alert, animated: true, completion: nil)
    }

    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        self.present(imagePickerController, animated: true)
    }
}

// MARK: UITextFieldDelegate

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        self.hidekeyboard()
        return true
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            dismiss(animated: true) {
                self.presentCropViewController(with: editedImage, pickerTitle: picker.title)
            }
        }
        dismiss(animated: true, completion: nil)
    }

    private func presentCropViewController(with image: UIImage, pickerTitle: String?) {
        let cropViewController = CropViewController(image: image)
        cropViewController.title = pickerTitle
        cropViewController.delegate = self
        cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        self.present(cropViewController, animated: true, completion: nil)
    }

    func cropViewController(_: CropViewController, didCropToImage image: UIImage, withRect _: CGRect, angle _: Int) {
        self.isImageSelected = true
        self.mProfile.image = image
        dismiss(animated: true, completion: nil)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.tableView.isHidden = self.places.isEmpty
        return self.places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "placescell", for: indexPath) as? GooglePlacesCell else {
            return GooglePlacesCell()
        }

        cell.name.text = self.places[indexPath.row].name ?? ""
        cell.mView.isUserInteractionEnabled = true
        let myGesture = MyGesture(target: self, action: #selector(self.locationCellClicked(myGesture:)))
        myGesture.index = indexPath.row
        cell.mView.addGestureRecognizer(myGesture)

        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            DispatchQueue.main.async {
                self.updateTableViewHeight()
            }
        }

        return cell
    }
}
