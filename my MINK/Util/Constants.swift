// Copyright © 2023 SOFTMENT. All rights reserved.

import Foundation
import UIKit
import CountryPicker

// MARK: - PriceID

/// Enumeration to represent different pricing options.
enum PriceID: String {
    case month = "in.softment.monthly"
    case year = "in.softment.yearly"
    case lifetime = "in.softment.lifetime"
}
// MARK: - Notifications

/// Enumeration to represent different pricing options.
enum Notifications : String {
  
    case like = "Like"
    case comment = "Comment"
    case following = "Following"
    case event = "Event"
    
}



// MARK: - SocialMedia

/// Enumeration to represent various social media platforms.
enum SocialMedia: String {
    case twitter = "Twitter"
    case instagram = "Instagram"
    case tiktok = "TikTok"
    case facebook = "Facebook"
    case youtube = "YouTube"
    case rumble = "Rumble"
    case twitch = "Twitch"
    case reddit = "Reddit"
    case tumblr = "Tumblr"
    case discord = "Discord"
    case telegram = "Telegram"
    case mastodon = "Mastodon"
    case pinterest = "Pinterest"
    case etsy = "Etsy"
    case linkedin = "LinkedIn"
    case whatsapp = "Whatsapp"
}

// MARK: - Collections

/// Enumeration to represent different Firestore collection names.
enum Collections: String {
    case users = "Users"
    case posts = "Posts"
    case savePosts = "SavePosts"
    case shares = "Shares"
    case likes = "Likes"
    case businesses = "Businesses"
    case subscribers = "Subscribers"
    case liveStreamings = "LiveStreamings"
    case horoscopes = "Horoscopes"
    case events = "Events"
    case tasks = "Tasks"
    case marketplace = "Marketplace"
    case profileViews = "ProfileViews"
    case following = "Following"
    case follow = "Follow"
    case tickets = "Tickets"
    case transactions = "Transactions"
    case chats = "Chats"
    case lastMessage = "LastMessage"
    case liveRecording = "LiveRecordings"
    case bot = "bot"
    case audiences = "Audiences"
    case feeds = "Feeds"
    case comments = "Comments"
    case socialMedia = "SocialMedia"
    case notifications = "Notifications"
}

// MARK: - PostType

/// Enumeration to represent different types of posts.
enum PostType: String {
    case image = "image"
    case video = "video"
    case text = "text"
}

// MARK: - SearchIndex

/// Enumeration to represent different search indexes.
enum SearchIndex: String {
    case posts = "Posts"
    case users = "Users"
    case events = "Events"
    case marketplace = "Marketplace"
    case businesses = "Businesses"
}

// MARK: - BranchIOFeature

/// Enumeration to represent different Branch IO features.
enum BranchIOFeature: String {
    case product = "PRODUCT"
    case liveStream = "LIVESTREAM"
    case userProfile = "USERPROFILE"
    case event = "EVENT"
    case post = "POST"
    case business = "BUSINESS"
}

// MARK: - Identifier

/// Enumeration to represent different view controller identifiers.
enum Identifier: String {
    case entryViewController = "entryVC"
    case completeProfileViewController = "completeProfileVC"
    case membershipViewController = "membershipVC"
    case tabBarViewController = "TabbarViewController"
    case homeViewController = "homeVC"
    case cameraViewController = "cameraVC"
    case profileViewController = "profileVC"
    case reelsViewController = "reelsVC"
    case liveStreamViewController = "liveStreamingVC"
    case searchViewController = "searchVC"
    case notificationController = "notificationVC"
    case organizerDashboardController = "organizerVC"
}

// MARK: - StoryBoard

/// Enumeration to represent different storyboard names.
enum StoryBoard: String {
    case main = "Main"
    case accountSetup = "AccountSetup"
    case tabBar = "Tabbar"
    case reels = "Reel"
    case liveStream = "LiveStreaming"
    case home = "Home"
    case profile = "Settings"
    case search = "Search"
    case notification = "Notification"
    case event = "Event"
}

// MARK: - AccountType

/// Enumeration to represent different account types.
enum AccountType: String {
    case user = "Users"
    case business = "Businesses"
}

// MARK: - Constants

/// Structure to hold constant values used across the application.
struct Constants {

    static var imageIndex = 0
    static var selectedTabBarPosition = 0
    static var currentDate = Date()
    static var createDate = Date()
    static let genders = ["Male", "Female", "Other"]
    static let productCategories = [
        "Automotive", "Books, Movies & Music", "Business & Industrial", "Electronics",
        "Fashion", "Health & Beauty", "Home & Garden", "Real Estate", "Services",
        "Sports & Outdoors", "Toys & Hobbies"
    ]

    static var allCountriesName: [String] {
        return CountryManager.shared.getCountries().map { $0.localizedName }
    }

    static var fromEventCreate = false
    static let myMinkAppDomain = "app.mymink.com.au/"
    static let awsVideoBaseURL = "https://d3uhzx9vktk5vy.cloudfront.net/public/"
    static let awsImageBaseURL = "https://d1bak4qdzgw57r.cloudfront.net"
    static var deeplinkData: [String: AnyObject]?
    static let spotifyClientID = "279e47a6baef4e2dadb963815ef165e1"
    static let spotifyClientSecret = "cc91f085b39a4b58a5c48c96c323d9bc"
    static let spotifyRedirectURI = "spotify-ios-quick-start://spotify-login-callback"
    static var spotifyAccessCode: String?
    static var spotifyAccessCodeDate: Date?
    static var channelName = ""
    static var callUUID: UUID!
    static var token = ""

    static var countryModels: [CountryModel]!
    static let countryJSONString = """
[
    {"name": "Afghanistan", "dial_code": "+93", "code": "AF", "currency": "AFN"},
    {"name": "Aland Islands", "dial_code": "+358", "code": "AX", "currency": "EUR"},
    {"name": "Albania", "dial_code": "+355", "code": "AL", "currency": "ALL"},
    {"name": "Algeria", "dial_code": "+213", "code": "DZ", "currency": "DZD"},
    {"name": "American Samoa", "dial_code": "+1684", "code": "AS", "currency": "USD"},
    {"name": "Andorra", "dial_code": "+376", "code": "AD", "currency": "EUR"},
    {"name": "Angola", "dial_code": "+244", "code": "AO", "currency": "AOA"},
    {"name": "Anguilla", "dial_code": "+1264", "code": "AI", "currency": "XCD"},
    {"name": "Antarctica", "dial_code": "+672", "code": "AQ", "currency": null},
    {"name": "Antigua and Barbuda", "dial_code": "+1268", "code": "AG", "currency": "XCD"},
    {"name": "Argentina", "dial_code": "+54", "code": "AR", "currency": "ARS"},
    {"name": "Armenia", "dial_code": "+374", "code": "AM", "currency": "AMD"},
    {"name": "Aruba", "dial_code": "+297", "code": "AW", "currency": "AWG"},
    {"name": "Australia", "dial_code": "+61", "code": "AU", "currency": "AUD"},
    {"name": "Austria", "dial_code": "+43", "code": "AT", "currency": "EUR"},
    {"name": "Azerbaijan", "dial_code": "+994", "code": "AZ", "currency": "AZN"},
    {"name": "Bahamas", "dial_code": "+1242", "code": "BS", "currency": "BSD"},
    {"name": "Bahrain", "dial_code": "+973", "code": "BH", "currency": "BHD"},
    {"name": "Bangladesh", "dial_code": "+880", "code": "BD", "currency": "BDT"},
    {"name": "Barbados", "dial_code": "+1246", "code": "BB", "currency": "BBD"},
    {"name": "Belarus", "dial_code": "+375", "code": "BY", "currency": "BYN"},
    {"name": "Belgium", "dial_code": "+32", "code": "BE", "currency": "EUR"},
    {"name": "Belize", "dial_code": "+501", "code": "BZ", "currency": "BZD"},
    {"name": "Benin", "dial_code": "+229", "code": "BJ", "currency": "XOF"},
    {"name": "Bermuda", "dial_code": "+1441", "code": "BM", "currency": "BMD"},
    {"name": "Bhutan", "dial_code": "+975", "code": "BT", "currency": "BTN"},
    {"name": "Bolivia, Plurinational State of", "dial_code": "+591", "code": "BO", "currency": "BOB"},
    {"name": "Bosnia and Herzegovina", "dial_code": "+387", "code": "BA", "currency": "BAM"},
    {"name": "Botswana", "dial_code": "+267", "code": "BW", "currency": "BWP"},
    {"name": "Brazil", "dial_code": "+55", "code": "BR", "currency": "BRL"},
    {"name": "British Indian Ocean Territory", "dial_code": "+246", "code": "IO", "currency": "USD"},
    {"name": "Brunei Darussalam", "dial_code": "+673", "code": "BN", "currency": "BND"},
    {"name": "Bulgaria", "dial_code": "+359", "code": "BG", "currency": "BGN"},
    {"name": "Burkina Faso", "dial_code": "+226", "code": "BF", "currency": "XOF"},
    {"name": "Burundi", "dial_code": "+257", "code": "BI", "currency": "BIF"},
    {"name": "Cambodia", "dial_code": "+855", "code": "KH", "currency": "KHR"},
    {"name": "Cameroon", "dial_code": "+237", "code": "CM", "currency": "XAF"},
    {"name": "Canada", "dial_code": "+1", "code": "CA", "currency": "CAD"},
    {"name": "Cape Verde", "dial_code": "+238", "code": "CV", "currency": "CVE"},
    {"name": "Cayman Islands", "dial_code": "+1345", "code": "KY", "currency": "KYD"},
    {"name": "Central African Republic", "dial_code": "+236", "code": "CF", "currency": "XAF"},
    {"name": "Chad", "dial_code": "+235", "code": "TD", "currency": "XAF"},
    {"name": "Chile", "dial_code": "+56", "code": "CL", "currency": "CLP"},
    {"name": "China", "dial_code": "+86", "code": "CN", "currency": "CNY"},
    {"name": "Christmas Island", "dial_code": "+61", "code": "CX", "currency": "AUD"},
    {"name": "Cocos (Keeling) Islands", "dial_code": "+61", "code": "CC", "currency": "AUD"},
    {"name": "Colombia", "dial_code": "+57", "code": "CO", "currency": "COP"},
    {"name": "Comoros", "dial_code": "+269", "code": "KM", "currency": "KMF"},
    {"name": "Congo", "dial_code": "+242", "code": "CG", "currency": "XAF"},
    {"name": "Congo, The Democratic Republic of the Congo", "dial_code": "+243", "code": "CD", "currency": "CDF"},
    {"name": "Cook Islands", "dial_code": "+682", "code": "CK", "currency": "NZD"},
    {"name": "Costa Rica", "dial_code": "+506", "code": "CR", "currency": "CRC"},
    {"name": "Cote d'Ivoire", "dial_code": "+225", "code": "CI", "currency": "XOF"},
    {"name": "Croatia", "dial_code": "+385", "code": "HR", "currency": "HRK"},
    {"name": "Cuba", "dial_code": "+53", "code": "CU", "currency": "CUP"},
    {"name": "Curacao", "dial_code": "+599", "code": "CW", "currency": "ANG"},
    {"name": "Cyprus", "dial_code": "+357", "code": "CY", "currency": "EUR"},
    {"name": "Czech Republic", "dial_code": "+420", "code": "CZ", "currency": "CZK"},
    {"name": "Denmark", "dial_code": "+45", "code": "DK", "currency": "DKK"},
    {"name": "Djibouti", "dial_code": "+253", "code": "DJ", "currency": "DJF"},
    {"name": "Dominica", "dial_code": "+1767", "code": "DM", "currency": "XCD"},
    {"name": "Dominican Republic", "dial_code": "+1", "code": "DO", "currency": "DOP"},
    {"name": "Ecuador", "dial_code": "+593", "code": "EC", "currency": "USD"},
    {"name": "Egypt", "dial_code": "+20", "code": "EG", "currency": "EGP"},
    {"name": "El Salvador", "dial_code": "+503", "code": "SV", "currency": "USD"},
    {"name": "Equatorial Guinea", "dial_code": "+240", "code": "GQ", "currency": "XAF"},
    {"name": "Eritrea", "dial_code": "+291", "code": "ER", "currency": "ERN"},
    {"name": "Estonia", "dial_code": "+372", "code": "EE", "currency": "EUR"},
    {"name": "Ethiopia", "dial_code": "+251", "code": "ET", "currency": "ETB"},
    {"name": "Falkland Islands (Malvinas)", "dial_code": "+500", "code": "FK", "currency": "FKP"},
    {"name": "Faroe Islands", "dial_code": "+298", "code": "FO", "currency": "DKK"},
    {"name": "Fiji", "dial_code": "+679", "code": "FJ", "currency": "FJD"},
    {"name": "Finland", "dial_code": "+358", "code": "FI", "currency": "EUR"},
    {"name": "France", "dial_code": "+33", "code": "FR", "currency": "EUR"},
    {"name": "French Guiana", "dial_code": "+594", "code": "GF", "currency": "EUR"},
    {"name": "French Polynesia", "dial_code": "+689", "code": "PF", "currency": "XPF"},
    {"name": "Gabon", "dial_code": "+241", "code": "GA", "currency": "XAF"},
    {"name": "Gambia", "dial_code": "+220", "code": "GM", "currency": "GMD"},
    {"name": "Georgia", "dial_code": "+995", "code": "GE", "currency": "GEL"},
    {"name": "Germany", "dial_code": "+49", "code": "DE", "currency": "EUR"},
    {"name": "Ghana", "dial_code": "+233", "code": "GH", "currency": "GHS"},
    {"name": "Gibraltar", "dial_code": "+350", "code": "GI", "currency": "GIP"},
    {"name": "Greece", "dial_code": "+30", "code": "GR", "currency": "EUR"},
    {"name": "Greenland", "dial_code": "+299", "code": "GL", "currency": "DKK"},
    {"name": "Grenada", "dial_code": "+1473", "code": "GD", "currency": "XCD"},
    {"name": "Guadeloupe", "dial_code": "+590", "code": "GP", "currency": "EUR"},
    {"name": "Guam", "dial_code": "+1671", "code": "GU", "currency": "USD"},
    {"name": "Guatemala", "dial_code": "+502", "code": "GT", "currency": "GTQ"},
    {"name": "Guernsey", "dial_code": "+44", "code": "GG", "currency": "GBP"},
    {"name": "Guinea", "dial_code": "+224", "code": "GN", "currency": "GNF"},
    {"name": "Guinea-Bissau", "dial_code": "+245", "code": "GW", "currency": "XOF"},
    {"name": "Guyana", "dial_code": "+592", "code": "GY", "currency": "GYD"},
    {"name": "Haiti", "dial_code": "+509", "code": "HT", "currency": "HTG"},
    {"name": "Holy See (Vatican City State)", "dial_code": "+379", "code": "VA", "currency": "EUR"},
    {"name": "Honduras", "dial_code": "+504", "code": "HN", "currency": "HNL"},
    {"name": "Hong Kong", "dial_code": "+852", "code": "HK", "currency": "HKD"},
    {"name": "Hungary", "dial_code": "+36", "code": "HU", "currency": "HUF"},
    {"name": "Iceland", "dial_code": "+354", "code": "IS", "currency": "ISK"},
    {"name": "India", "dial_code": "+91", "code": "IN", "currency": "INR"},
    {"name": "Indonesia", "dial_code": "+62", "code": "ID", "currency": "IDR"},
    {"name": "Iran", "dial_code": "+98", "code": "IR", "currency": "IRR"},
    {"name": "Iraq", "dial_code": "+964", "code": "IQ", "currency": "IQD"},
    {"name": "Ireland", "dial_code": "+353", "code": "IE", "currency": "EUR"},
    {"name": "Isle of Man", "dial_code": "+44", "code": "IM", "currency": "GBP"},
    {"name": "Israel", "dial_code": "+972", "code": "IL", "currency": "ILS"},
    {"name": "Italy", "dial_code": "+39", "code": "IT", "currency": "EUR"},
    {"name": "Jamaica", "dial_code": "+876", "code": "JM", "currency": "JMD"},
    {"name": "Japan", "dial_code": "+81", "code": "JP", "currency": "JPY"},
    {"name": "Jersey", "dial_code": "+44", "code": "JE", "currency": "GBP"},
    {"name": "Jordan", "dial_code": "+962", "code": "JO", "currency": "JOD"},
    {"name": "Kazakhstan", "dial_code": "+7", "code": "KZ", "currency": "KZT"},
    {"name": "Kenya", "dial_code": "+254", "code": "KE", "currency": "KES"},
    {"name": "Kiribati", "dial_code": "+686", "code": "KI", "currency": "AUD"},
    {"name": "Kosovo", "dial_code": "+383", "code": "XK", "currency": "EUR"},
    {"name": "Kuwait", "dial_code": "+965", "code": "KW", "currency": "KWD"},
    {"name": "Kyrgyzstan", "dial_code": "+996", "code": "KG", "currency": "KGS"},
    {"name": "Laos", "dial_code": "+856", "code": "LA", "currency": "LAK"},
    {"name": "Latvia", "dial_code": "+371", "code": "LV", "currency": "EUR"},
    {"name": "Lebanon", "dial_code": "+961", "code": "LB", "currency": "LBP"},
    {"name": "Lesotho", "dial_code": "+266", "code": "LS", "currency": "LSL"},
    {"name": "Liberia", "dial_code": "+231", "code": "LR", "currency": "LRD"},
    {"name": "Libyan Arab Jamahiriya", "dial_code": "+218", "code": "LY", "currency": "LYD"},
    {"name": "Liechtenstein", "dial_code": "+423", "code": "LI", "currency": "CHF"},
    {"name": "Lithuania", "dial_code": "+370", "code": "LT", "currency": "EUR"},
    {"name": "Luxembourg", "dial_code": "+352", "code": "LU", "currency": "EUR"},
    {"name": "Macao", "dial_code": "+853", "code": "MO", "currency": "MOP"},
    {"name": "Macedonia", "dial_code": "+389", "code": "MK", "currency": "MKD"},
    {"name": "Madagascar", "dial_code": "+261", "code": "MG", "currency": "MGA"},
    {"name": "Malawi", "dial_code": "+265", "code": "MW", "currency": "MWK"},
    {"name": "Malaysia", "dial_code": "+60", "code": "MY", "currency": "MYR"},
    {"name": "Maldives", "dial_code": "+960", "code": "MV", "currency": "MVR"},
    {"name": "Mali", "dial_code": "+223", "code": "ML", "currency": "XOF"},
    {"name": "Malta", "dial_code": "+356", "code": "MT", "currency": "EUR"},
    {"name": "Marshall Islands", "dial_code": "+692", "code": "MH", "currency": "USD"},
    {"name": "Martinique", "dial_code": "+596", "code": "MQ", "currency": "EUR"},
    {"name": "Mauritania", "dial_code": "+222", "code": "MR", "currency": "MRO"},
    {"name": "Mauritius", "dial_code": "+230", "code": "MU", "currency": "MUR"},
    {"name": "Mayotte", "dial_code": "+262", "code": "YT", "currency": "EUR"},
    {"name": "Mexico", "dial_code": "+52", "code": "MX", "currency": "MXN"},
    {"name": "Micronesia, Federated States of Micronesia", "dial_code": "+691", "code": "FM", "currency": "USD"},
    {"name": "Moldova", "dial_code": "+373", "code": "MD", "currency": "MDL"},
    {"name": "Monaco", "dial_code": "+377", "code": "MC", "currency": "EUR"},
    {"name": "Mongolia", "dial_code": "+976", "code": "MN", "currency": "MNT"},
    {"name": "Montenegro", "dial_code": "+382", "code": "ME", "currency": "EUR"},
    {"name": "Montserrat", "dial_code": "+1664", "code": "MS", "currency": "XCD"},
    {"name": "Morocco", "dial_code": "+212", "code": "MA", "currency": "MAD"},
    {"name": "Mozambique", "dial_code": "+258", "code": "MZ", "currency": "MZN"},
    {"name": "Myanmar", "dial_code": "+95", "code": "MM", "currency": "MMK"},
    {"name": "Namibia", "dial_code": "+264", "code": "NA", "currency": "NAD"},
    {"name": "Nauru", "dial_code": "+674", "code": "NR", "currency": "AUD"},
    {"name": "Nepal", "dial_code": "+977", "code": "NP", "currency": "NPR"},
    {"name": "Netherlands", "dial_code": "+31", "code": "NL", "currency": "EUR"},
    {"name": "New Caledonia", "dial_code": "+687", "code": "NC", "currency": "XPF"},
    {"name": "New Zealand", "dial_code": "+64", "code": "NZ", "currency": "NZD"},
    {"name": "Nicaragua", "dial_code": "+505", "code": "NI", "currency": "NIO"},
    {"name": "Niger", "dial_code": "+227", "code": "NE", "currency": "XOF"},
    {"name": "Nigeria", "dial_code": "+234", "code": "NG", "currency": "NGN"},
    {"name": "Niue", "dial_code": "+683", "code": "NU", "currency": "NZD"},
    {"name": "Norfolk Island", "dial_code": "+672", "code": "NF", "currency": "AUD"},
    {"name": "North Korea", "dial_code": "+850", "code": "KP", "currency": "KPW"},
    {"name": "Northern Mariana Islands", "dial_code": "+1670", "code": "MP", "currency": "USD"},
    {"name": "Norway", "dial_code": "+47", "code": "NO", "currency": "NOK"},
    {"name": "Oman", "dial_code": "+968", "code": "OM", "currency": "OMR"},
    {"name": "Pakistan", "dial_code": "+92", "code": "PK", "currency": "PKR"},
    {"name": "Palau", "dial_code": "+680", "code": "PW", "currency": "USD"},
    {"name": "Palestine", "dial_code": "+970", "code": "PS", "currency": "ILS"},
    {"name": "Panama", "dial_code": "+507", "code": "PA", "currency": "PAB"},
    {"name": "Papua New Guinea", "dial_code": "+675", "code": "PG", "currency": "PGK"},
    {"name": "Paraguay", "dial_code": "+595", "code": "PY", "currency": "PYG"},
    {"name": "Peru", "dial_code": "+51", "code": "PE", "currency": "PEN"},
    {"name": "Philippines", "dial_code": "+63", "code": "PH", "currency": "PHP"},
    {"name": "Pitcairn", "dial_code": "+64", "code": "PN", "currency": "NZD"},
    {"name": "Poland", "dial_code": "+48", "code": "PL", "currency": "PLN"},
    {"name": "Portugal", "dial_code": "+351", "code": "PT", "currency": "EUR"},
    {"name": "Puerto Rico", "dial_code": "+1", "code": "PR", "currency": "USD"},
    {"name": "Qatar", "dial_code": "+974", "code": "QA", "currency": "QAR"},
    {"name": "Reunion", "dial_code": "+262", "code": "RE", "currency": "EUR"},
    {"name": "Romania", "dial_code": "+40", "code": "RO", "currency": "RON"},
    {"name": "Russia", "dial_code": "+7", "code": "RU", "currency": "RUB"},
    {"name": "Rwanda", "dial_code": "+250", "code": "RW", "currency": "RWF"},
    {"name": "Saint Barthelemy", "dial_code": "+590", "code": "BL", "currency": "EUR"},
    {"name": "Saint Helena, Ascension and Tristan Da Cunha", "dial_code": "+290", "code": "SH", "currency": "SHP"},
    {"name": "Saint Kitts and Nevis", "dial_code": "+1869", "code": "KN", "currency": "XCD"},
    {"name": "Saint Lucia", "dial_code": "+1758", "code": "LC", "currency": "XCD"},
    {"name": "Saint Martin", "dial_code": "+590", "code": "MF", "currency": "EUR"},
    {"name": "Saint Pierre and Miquelon", "dial_code": "+508", "code": "PM", "currency": "EUR"},
    {"name": "Saint Vincent and the Grenadines", "dial_code": "+1784", "code": "VC", "currency": "XCD"},
    {"name": "Samoa", "dial_code": "+685", "code": "WS", "currency": "WST"},
    {"name": "San Marino", "dial_code": "+378", "code": "SM", "currency": "EUR"},
    {"name": "Sao Tome and Principe", "dial_code": "+239", "code": "ST", "currency": "STN"},
    {"name": "Saudi Arabia", "dial_code": "+966", "code": "SA", "currency": "SAR"},
    {"name": "Senegal", "dial_code": "+221", "code": "SN", "currency": "XOF"},
    {"name": "Serbia", "dial_code": "+381", "code": "RS", "currency": "RSD"},
    {"name": "Seychelles", "dial_code": "+248", "code": "SC", "currency": "SCR"},
    {"name": "Sierra Leone", "dial_code": "+232", "code": "SL", "currency": "SLL"},
    {"name": "Singapore", "dial_code": "+65", "code": "SG", "currency": "SGD"},
    {"name": "Sint Maarten", "dial_code": "+1721", "code": "SX", "currency": "ANG"},
    {"name": "Slovakia", "dial_code": "+421", "code": "SK", "currency": "EUR"},
    {"name": "Slovenia", "dial_code": "+386", "code": "SI", "currency": "EUR"},
    {"name": "Solomon Islands", "dial_code": "+677", "code": "SB", "currency": "SBD"},
    {"name": "Somalia", "dial_code": "+252", "code": "SO", "currency": "SOS"},
    {"name": "South Africa", "dial_code": "+27", "code": "ZA", "currency": "ZAR"},
    {"name": "South Korea", "dial_code": "+82", "code": "KR", "currency": "KRW"},
    {"name": "South Sudan", "dial_code": "+211", "code": "SS", "currency": "SSP"},
    {"name": "Spain", "dial_code": "+34", "code": "ES", "currency": "EUR"},
    {"name": "Sri Lanka", "dial_code": "+94", "code": "LK", "currency": "LKR"},
    {"name": "Sudan", "dial_code": "+249", "code": "SD", "currency": "SDG"},
    {"name": "Suriname", "dial_code": "+597", "code": "SR", "currency": "SRD"},
    {"name": "Svalbard and Jan Mayen", "dial_code": "+47", "code": "SJ", "currency": "NOK"},
    {"name": "Swaziland", "dial_code": "+268", "code": "SZ", "currency": "SZL"},
    {"name": "Sweden", "dial_code": "+46", "code": "SE", "currency": "SEK"},
    {"name": "Switzerland", "dial_code": "+41", "code": "CH", "currency": "CHF"},
    {"name": "Syrian Arab Republic", "dial_code": "+963", "code": "SY", "currency": "SYP"},
    {"name": "Taiwan", "dial_code": "+886", "code": "TW", "currency": "TWD"},
    {"name": "Tajikistan", "dial_code": "+992", "code": "TJ", "currency": "TJS"},
    {"name": "Tanzania", "dial_code": "+255", "code": "TZ", "currency": "TZS"},
    {"name": "Thailand", "dial_code": "+66", "code": "TH", "currency": "THB"},
    {"name": "Timor-Leste", "dial_code": "+670", "code": "TL", "currency": "USD"},
    {"name": "Togo", "dial_code": "+228", "code": "TG", "currency": "XOF"},
    {"name": "Tokelau", "dial_code": "+690", "code": "TK", "currency": "NZD"},
    {"name": "Tonga", "dial_code": "+676", "code": "TO", "currency": "TOP"},
    {"name": "Trinidad and Tobago", "dial_code": "+1868", "code": "TT", "currency": "TTD"},
    {"name": "Tunisia", "dial_code": "+216", "code": "TN", "currency": "TND"},
    {"name": "Turkey", "dial_code": "+90", "code": "TR", "currency": "TRY"},
    {"name": "Turkmenistan", "dial_code": "+993", "code": "TM", "currency": "TMT"},
    {"name": "Turks and Caicos Islands", "dial_code": "+1649", "code": "TC", "currency": "USD"},
    {"name": "Tuvalu", "dial_code": "+688", "code": "TV", "currency": "AUD"},
    {"name": "Uganda", "dial_code": "+256", "code": "UG", "currency": "UGX"},
    {"name": "Ukraine", "dial_code": "+380", "code": "UA", "currency": "UAH"},
    {"name": "United Arab Emirates", "dial_code": "+971", "code": "AE", "currency": "AED"},
    {"name": "United Kingdom", "dial_code": "+44", "code": "GB", "currency": "GBP"},
    {"name": "United States", "dial_code": "+1", "code": "US", "currency": "USD"},
    {"name": "Uruguay", "dial_code": "+598", "code": "UY", "currency": "UYU"},
    {"name": "Uzbekistan", "dial_code": "+998", "code": "UZ", "currency": "UZS"},
    {"name": "Vanuatu", "dial_code": "+678", "code": "VU", "currency": "VUV"},
    {"name": "Venezuela", "dial_code": "+58", "code": "VE", "currency": "VES"},
    {"name": "Vietnam", "dial_code": "+84", "code": "VN", "currency": "VND"},
    {"name": "Wallis and Futuna", "dial_code": "+681", "code": "WF", "currency": "XPF"},
    {"name": "Western Sahara", "dial_code": "+212", "code": "EH", "currency": "MAD"},
    {"name": "Yemen", "dial_code": "+967", "code": "YE", "currency": "YER"},
    {"name": "Zambia", "dial_code": "+260", "code": "ZM", "currency": "ZMW"},
    {"name": "Zimbabwe", "dial_code": "+263", "code": "ZW", "currency": "ZWL"}
]
"""
    static let businessTypes = [
        "Agriculture and Mining", "Arts and Entertainment", "Automotive", "Beauty and Cosmetics", "Biotechnology",
        "Construction", "Consulting", "Education", "Education and Training", "Electronics", "Energy",
        "Environmental Services", "Fashion and Apparel", "Finance and Insurance", "Food and Beverage",
        "Health and Wellness", "Healthcare", "Hospitality and Tourism", "Information Technology", "Legal Services",
        "Logistics", "Manufacturing", "Marketing and Advertising", "Media", "Non-Profit", "Personal Services",
        "Pharmaceuticals", "Professional Services", "Publishing", "Public Sector", "Real Estate", "Recreation and Leisure",
        "Retail", "Scientific Services", "Security Services", "Software Development", "Technical Services",
        "Telecommunications", "Transportation and Warehousing", "Utilities", "Wholesale Trade"
    ]
}
