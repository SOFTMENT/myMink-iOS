// Copyright © 2023 SOFTMENT. All rights reserved.


import Foundation
import UIKit
import CountryPicker

// MARK: - PriceID

enum PriceID: String {
    case MONTH = "ID_MONTHLY"
    case YEAR = "ID_YEARLY"
    case LIFETIME = "ID_LIFETIME"
}


// MARK: - SocialMedia
enum SocialMedia : String{
    case Twitter
    case Instagram
    case TikTok
    case Facebook
    case YouTube
    case Rumble
    case Twitch
    case Reddit
    case Tumblr
    case Discord
    case Telegram
    case Mastodon
    case Pinterest
    case Etsy
    case LinkedIn
    case Whatsapp
 
}

// MARK: - Collection
enum Collections : String {
    case USERS = "Users"
    case POSTS = "Posts"
    case SAVEPOSTS = "SavePosts"
    case SHARES = "Shares"
    case LIKES = "Likes"
    case BUSINESSES = "Businesses"
    case SUBSCRIBERS = "Subscribers"
    case LIVESTREAMINGS = "LiveStreamings"
    case HOROSCOPES = "Horoscopes"
    case EVENTS = "Events"
    case TASKS = "Tasks"
    case MARKETPLACE = "Marketplace"
    case PROFILEVIEWS = "ProfileViews"
    case FOLLOWING = "Following"
    case FOLLOW = "Follow"
    case TICKETS = "Tickets"
    case TRANSACTIONS = "Transactions"
    case CHATS = "Chats"
    case LASTMESSAGE = "LastMessage"
    case LIVERECORDING = "LiveRecordings"
    case BOT = "bot"
    case AUDIENCES = "Audiences"
    case FEEDS = "Feeds"
    case COMMENTS = "Comments"
    case SOCIALMEDIA = "SocialMedia"
}

// MARK: - PostType

enum PostType : String {
    case IMAGE = "image"
    case VIDEO = "video"
    case TEXT = "text"
}

enum SearchIndex : String {
    case POSTS = "Posts"
    case USERS = "Users"
    case EVENTS = "Events"
    case MARKETPLACE = "Marketplace"
}

enum BranchIOFeature : String {
    case PRODUCT
    case LIVESTREAM
    case USERPROFILE
    case EVENT
    case POST
    case BUSINESS
}

// MARK: - Identifier

enum Identifier: String {
    
    case ENTRYVIEWCONTROLLER = "entryVC"
    case COMPLETEPROFILEVIEWCONTROLLER = "completeProfileVC"
    case MEMBERSHIPVIEWCONTROLLER = "membershipVC"
    case TABBARVIEWCONTROLLER = "TabbarViewController"
    case HOMEVIEWCONTROLLER = "homeVC"
    case CAMERAVIEWCONTROLLER = "cameraVC"
    case PROFILEVIEWCONTROLLER = "profileVC"
    case REELSVIEWCONTROLLER = "reelsVC"
    case LIVESTREAMVIEWCONTROLLER = "liveStreamingVC"
    case SEARCHVIEWCONTROLLER = "searchVC"
    case NOTIFICATIONCONTROLLER = "notificationVC"
    case ORGANIZERDASHBOARDCONTROLLER = "organizerVC"
    
}

// MARK: - StoryBoard

enum StoryBoard: String {
    case Main
    case AccountSetup
    case Tabbar
    case Reels = "Reel"
    case LiveStream = "LiveStreaming"
    case Home
    case Profile = "Settings"
    case Search
    case Notification
    case Event

}

enum AccountType : String{
    case USER = "Users"
    case BUSINESS = "Businesses"
}


// MARK: - Constants

struct Constants {
    static var imageIndex = 0
    static var selectedTabbarPosition = 0
    static var currentDate = Date()
    static var createDate = Date()
    static let genders = ["Male", "Female", "Other"]
    static let product_categories = [
        "Automotive",
        "Books, Movies & Music",
        "Business & Industrial",
        "Electronics",
        "Fashion",
        "Health & Beauty",
        "Home & Garden",
        "Real Estate",
        "Services",
        "Sports & Outdoors",
        "Toys & Hobbies"
    ]
    
    
    static var allCountriesName : [String] {
        var countries = Array<String>()
        for country in CountryManager.shared.getCountries() {
            countries.append(country.localizedName)
        }
        return countries
    }
    
    

    static var FROM_EVENT_CREATE = false
    static let BLUE_TICK_REQUIREMENT = 10
    static let MY_MINK_APP_DOMAIN = "app.mymink.com.au/"
    static let AWS_VIDEO_BASE_URL = "https://d3uhzx9vktk5vy.cloudfront.net/public/"
    static let AWS_IMAGE_BASE_URL = "https://d1bak4qdzgw57r.cloudfront.net"
    static var deeplink_data: [String: AnyObject]?
    static let spotify_clientID = "279e47a6baef4e2dadb963815ef165e1"
    static let spotify_clientSecret = "cc91f085b39a4b58a5c48c96c323d9bc"
    static let spotify_redirectURI = "spotify-ios-quick-start://spotify-login-callback"
    static var spotify_access_code: String?
    static var spotify_access_code_date: Date?
    static var channelName = ""
    static var callUUID: UUID!
    static var token = ""
    static var hasBlueTick = false
 
    public static var countryModels : Array<CountryModel>!
    public static let countryJSONString = """
[
    {
        "name": "Afghanistan",
        "dial_code": "+93",
        "code": "AF",
        "currency": "AFN"
    },
    {
        "name": "Aland Islands",
        "dial_code": "+358",
        "code": "AX",
        "currency": "EUR"
    },
    {
        "name": "Albania",
        "dial_code": "+355",
        "code": "AL",
        "currency": "ALL"
    },
    {
        "name": "Algeria",
        "dial_code": "+213",
        "code": "DZ",
        "currency": "DZD"
    },
    {
        "name": "American Samoa",
        "dial_code": "+1684",
        "code": "AS",
        "currency": "USD"
    },
    {
        "name": "Andorra",
        "dial_code": "+376",
        "code": "AD",
        "currency": "EUR"
    },
    {
        "name": "Angola",
        "dial_code": "+244",
        "code": "AO",
        "currency": "AOA"
    },
    {
        "name": "Anguilla",
        "dial_code": "+1264",
        "code": "AI",
        "currency": "XCD"
    },
    {
        "name": "Antarctica",
        "dial_code": "+672",
        "code": "AQ",
        "currency": null
    },
    {
        "name": "Antigua and Barbuda",
        "dial_code": "+1268",
        "code": "AG",
        "currency": "XCD"
    },
    {
        "name": "Argentina",
        "dial_code": "+54",
        "code": "AR",
        "currency": "ARS"
    },
    {
        "name": "Armenia",
        "dial_code": "+374",
        "code": "AM",
        "currency": "AMD"
    },
    {
        "name": "Aruba",
        "dial_code": "+297",
        "code": "AW",
        "currency": "AWG"
    },
    {
        "name": "Australia",
        "dial_code": "+61",
        "code": "AU",
        "currency": "AUD"
    },
    {
        "name": "Austria",
        "dial_code": "+43",
        "code": "AT",
        "currency": "EUR"
    },
    {
        "name": "Azerbaijan",
        "dial_code": "+994",
        "code": "AZ",
        "currency": "AZN"
    },
    {
        "name": "Bahamas",
        "dial_code": "+1242",
        "code": "BS",
        "currency": "BSD"
    },
    {
        "name": "Bahrain",
        "dial_code": "+973",
        "code": "BH",
        "currency": "BHD"
    },
    {
        "name": "Bangladesh",
        "dial_code": "+880",
        "code": "BD",
        "currency": "BDT"
    },
    {
        "name": "Barbados",
        "dial_code": "+1246",
        "code": "BB",
        "currency": "BBD"
    },
    {
        "name": "Belarus",
        "dial_code": "+375",
        "code": "BY",
        "currency": "BYN"
    },
    {
        "name": "Belgium",
        "dial_code": "+32",
        "code": "BE",
        "currency": "EUR"
    },
    {
        "name": "Belize",
        "dial_code": "+501",
        "code": "BZ",
        "currency": "BZD"
    },
    {
        "name": "Benin",
        "dial_code": "+229",
        "code": "BJ",
        "currency": "XOF"
    },
    {
        "name": "Bermuda",
        "dial_code": "+1441",
        "code": "BM",
        "currency": "BMD"
    },
    {
        "name": "Bhutan",
        "dial_code": "+975",
        "code": "BT",
        "currency": "BTN"
    },
    {
        "name": "Bolivia, Plurinational State of",
        "dial_code": "+591",
        "code": "BO",
        "currency": "BOB"
    },
    {
        "name": "Bosnia and Herzegovina",
        "dial_code": "+387",
        "code": "BA",
        "currency": "BAM"
    },
    {
        "name": "Botswana",
        "dial_code": "+267",
        "code": "BW",
        "currency": "BWP"
    },
    {
        "name": "Brazil",
        "dial_code": "+55",
        "code": "BR",
        "currency": "BRL"
    },
    {
        "name": "British Indian Ocean Territory",
        "dial_code": "+246",
        "code": "IO",
        "currency": "USD"
    },
    {
        "name": "Brunei Darussalam",
        "dial_code": "+673",
        "code": "BN",
        "currency": "BND"
    },
    {
        "name": "Bulgaria",
        "dial_code": "+359",
        "code": "BG",
        "currency": "BGN"
    },
    {
        "name": "Burkina Faso",
        "dial_code": "+226",
        "code": "BF",
        "currency": "XOF"
    },
    {
        "name": "Burundi",
        "dial_code": "+257",
        "code": "BI",
        "currency": "BIF"
    },
 {
        "name": "Cambodia",
        "dial_code": "+855",
        "code": "KH",
        "currency": "KHR"
    },
    {
        "name": "Cameroon",
        "dial_code": "+237",
        "code": "CM",
        "currency": "XAF"
    },
    {
        "name": "Canada",
        "dial_code": "+1",
        "code": "CA",
        "currency": "CAD"
    },
    {
        "name": "Cape Verde",
        "dial_code": "+238",
        "code": "CV",
        "currency": "CVE"
    },
    {
        "name": "Cayman Islands",
        "dial_code": "+1345",
        "code": "KY",
        "currency": "KYD"
    },
    {
        "name": "Central African Republic",
        "dial_code": "+236",
        "code": "CF",
        "currency": "XAF"
    },
    {
        "name": "Chad",
        "dial_code": "+235",
        "code": "TD",
        "currency": "XAF"
    },
    {
        "name": "Chile",
        "dial_code": "+56",
        "code": "CL",
        "currency": "CLP"
    },
    {
        "name": "China",
        "dial_code": "+86",
        "code": "CN",
        "currency": "CNY"
    },
    {
        "name": "Christmas Island",
        "dial_code": "+61",
        "code": "CX",
        "currency": "AUD"
    },
    {
        "name": "Cocos (Keeling) Islands",
        "dial_code": "+61",
        "code": "CC",
        "currency": "AUD"
    },
    {
        "name": "Colombia",
        "dial_code": "+57",
        "code": "CO",
        "currency": "COP"
    },
    {
        "name": "Comoros",
        "dial_code": "+269",
        "code": "KM",
        "currency": "KMF"
    },
    {
        "name": "Congo",
        "dial_code": "+242",
        "code": "CG",
        "currency": "XAF"
    },
    {
        "name": "Congo, The Democratic Republic of the Congo",
        "dial_code": "+243",
        "code": "CD",
        "currency": "CDF"
    },
    {
        "name": "Cook Islands",
        "dial_code": "+682",
        "code": "CK",
        "currency": "NZD"
    },
    {
        "name": "Costa Rica",
        "dial_code": "+506",
        "code": "CR",
        "currency": "CRC"
    },
    {
        "name": "Cote d'Ivoire",
        "dial_code": "+225",
        "code": "CI",
        "currency": "XOF"
    },
    {
        "name": "Croatia",
        "dial_code": "+385",
        "code": "HR",
        "currency": "HRK"
    },
    {
        "name": "Cuba",
        "dial_code": "+53",
        "code": "CU",
        "currency": "CUP"
    },
    {
        "name": "Curacao",
        "dial_code": "+599",
        "code": "CW",
        "currency": "ANG"
    },
    {
        "name": "Cyprus",
        "dial_code": "+357",
        "code": "CY",
        "currency": "EUR"
    },
    {
        "name": "Czech Republic",
        "dial_code": "+420",
        "code": "CZ",
        "currency": "CZK"
    },
    {
        "name": "Denmark",
        "dial_code": "+45",
        "code": "DK",
        "currency": "DKK"
    },
    {
        "name": "Djibouti",
        "dial_code": "+253",
        "code": "DJ",
        "currency": "DJF"
    },
    {
        "name": "Dominica",
        "dial_code": "+1767",
        "code": "DM",
        "currency": "XCD"
    },
    {
        "name": "Dominican Republic",
        "dial_code": "+1",
        "code": "DO",
        "currency": "DOP"
    },
    {
        "name": "Ecuador",
        "dial_code": "+593",
        "code": "EC",
        "currency": "USD"
    },
    {
        "name": "Egypt",
        "dial_code": "+20",
        "code": "EG",
        "currency": "EGP"
    },
    {
        "name": "El Salvador",
        "dial_code": "+503",
        "code": "SV",
        "currency": "USD"
    },
    {
        "name": "Equatorial Guinea",
        "dial_code": "+240",
        "code": "GQ",
        "currency": "XAF"
    },
    {
        "name": "Eritrea",
        "dial_code": "+291",
        "code": "ER",
        "currency": "ERN"
    },
    {
        "name": "Estonia",
        "dial_code": "+372",
        "code": "EE",
        "currency": "EUR"
    },
{
        "name": "Ethiopia",
        "dial_code": "+251",
        "code": "ET",
        "currency": "ETB"
    },
    {
        "name": "Falkland Islands (Malvinas)",
        "dial_code": "+500",
        "code": "FK",
        "currency": "FKP"
    },
    {
        "name": "Faroe Islands",
        "dial_code": "+298",
        "code": "FO",
        "currency": "DKK"
    },
    {
        "name": "Fiji",
        "dial_code": "+679",
        "code": "FJ",
        "currency": "FJD"
    },
    {
        "name": "Finland",
        "dial_code": "+358",
        "code": "FI",
        "currency": "EUR"
    },
    {
        "name": "France",
        "dial_code": "+33",
        "code": "FR",
        "currency": "EUR"
    },
    {
        "name": "French Guiana",
        "dial_code": "+594",
        "code": "GF",
        "currency": "EUR"
    },
    {
        "name": "French Polynesia",
        "dial_code": "+689",
        "code": "PF",
        "currency": "XPF"
    },
    {
        "name": "Gabon",
        "dial_code": "+241",
        "code": "GA",
        "currency": "XAF"
    },
    {
        "name": "Gambia",
        "dial_code": "+220",
        "code": "GM",
        "currency": "GMD"
    },
    {
        "name": "Georgia",
        "dial_code": "+995",
        "code": "GE",
        "currency": "GEL"
    },
    {
        "name": "Germany",
        "dial_code": "+49",
        "code": "DE",
        "currency": "EUR"
    },
    {
        "name": "Ghana",
        "dial_code": "+233",
        "code": "GH",
        "currency": "GHS"
    },
    {
        "name": "Gibraltar",
        "dial_code": "+350",
        "code": "GI",
        "currency": "GIP"
    },
    {
        "name": "Greece",
        "dial_code": "+30",
        "code": "GR",
        "currency": "EUR"
    },
    {
        "name": "Greenland",
        "dial_code": "+299",
        "code": "GL",
        "currency": "DKK"
    },
    {
        "name": "Grenada",
        "dial_code": "+1473",
        "code": "GD",
        "currency": "XCD"
    },
    {
        "name": "Guadeloupe",
        "dial_code": "+590",
        "code": "GP",
        "currency": "EUR"
    },
    {
        "name": "Guam",
        "dial_code": "+1671",
        "code": "GU",
        "currency": "USD"
    },
    {
        "name": "Guatemala",
        "dial_code": "+502",
        "code": "GT",
        "currency": "GTQ"
    },
    {
        "name": "Guernsey",
        "dial_code": "+44",
        "code": "GG",
        "currency": "GBP"
    },
    {
        "name": "Guinea",
        "dial_code": "+224",
        "code": "GN",
        "currency": "GNF"
    },
    {
        "name": "Guinea-Bissau",
        "dial_code": "+245",
        "code": "GW",
        "currency": "XOF"
    },
    {
        "name": "Guyana",
        "dial_code": "+592",
        "code": "GY",
        "currency": "GYD"
    },
    {
        "name": "Haiti",
        "dial_code": "+509",
        "code": "HT",
        "currency": "HTG"
    },
    {
        "name": "Holy See (Vatican City State)",
        "dial_code": "+379",
        "code": "VA",
        "currency": "EUR"
    },
    {
        "name": "Honduras",
        "dial_code": "+504",
        "code": "HN",
        "currency": "HNL"
    },
    {
        "name": "Hong Kong",
        "dial_code": "+852",
        "code": "HK",
        "currency": "HKD"
    },
    {
        "name": "Hungary",
        "dial_code": "+36",
        "code": "HU",
        "currency": "HUF"
    },
 {
        "name": "Iceland",
        "dial_code": "+354",
        "code": "IS",
        "currency": "ISK"
    },
    {
        "name": "India",
        "dial_code": "+91",
        "code": "IN",
        "currency": "INR"
    },
    {
        "name": "Indonesia",
        "dial_code": "+62",
        "code": "ID",
        "currency": "IDR"
    },
    {
        "name": "Iran",
        "dial_code": "+98",
        "code": "IR",
        "currency": "IRR"
    },
    {
        "name": "Iraq",
        "dial_code": "+964",
        "code": "IQ",
        "currency": "IQD"
    },
    {
        "name": "Ireland",
        "dial_code": "+353",
        "code": "IE",
        "currency": "EUR"
    },
    {
        "name": "Isle of Man",
        "dial_code": "+44",
        "code": "IM",
        "currency": "GBP"
    },
    {
        "name": "Israel",
        "dial_code": "+972",
        "code": "IL",
        "currency": "ILS"
    },
    {
        "name": "Italy",
        "dial_code": "+39",
        "code": "IT",
        "currency": "EUR"
    },
    {
        "name": "Jamaica",
        "dial_code": "+876",
        "code": "JM",
        "currency": "JMD"
    },
    {
        "name": "Japan",
        "dial_code": "+81",
        "code": "JP",
        "currency": "JPY"
    },
    {
        "name": "Jersey",
        "dial_code": "+44",
        "code": "JE",
        "currency": "GBP"
    },
    {
        "name": "Jordan",
        "dial_code": "+962",
        "code": "JO",
        "currency": "JOD"
    },
    {
        "name": "Kazakhstan",
        "dial_code": "+7",
        "code": "KZ",
        "currency": "KZT"
    },
    {
        "name": "Kenya",
        "dial_code": "+254",
        "code": "KE",
        "currency": "KES"
    },
    {
        "name": "Kiribati",
        "dial_code": "+686",
        "code": "KI",
        "currency": "AUD"
    },
    {
        "name": "Kosovo",
        "dial_code": "+383",
        "code": "XK",
        "currency": "EUR"
    },
    {
        "name": "Kuwait",
        "dial_code": "+965",
        "code": "KW",
        "currency": "KWD"
    },
    {
        "name": "Kyrgyzstan",
        "dial_code": "+996",
        "code": "KG",
        "currency": "KGS"
    },
    {
        "name": "Laos",
        "dial_code": "+856",
        "code": "LA",
        "currency": "LAK"
    },
    {
        "name": "Latvia",
        "dial_code": "+371",
        "code": "LV",
        "currency": "EUR"
    },
    {
        "name": "Lebanon",
        "dial_code": "+961",
        "code": "LB",
        "currency": "LBP"
    },
    {
        "name": "Lesotho",
        "dial_code": "+266",
        "code": "LS",
        "currency": "LSL"
    },
    {
        "name": "Liberia",
        "dial_code": "+231",
        "code": "LR",
        "currency": "LRD"
    },
    {
        "name": "Libyan Arab Jamahiriya",
        "dial_code": "+218",
        "code": "LY",
        "currency": "LYD"
    },
    {
        "name": "Liechtenstein",
        "dial_code": "+423",
        "code": "LI",
        "currency": "CHF"
    },
    {
        "name": "Lithuania",
        "dial_code": "+370",
        "code": "LT",
        "currency": "EUR"
    },
    {
        "name": "Luxembourg",
        "dial_code": "+352",
        "code": "LU",
        "currency": "EUR"
    },
    {
        "name": "Macao",
        "dial_code": "+853",
        "code": "MO",
        "currency": "MOP"
    },
    {
        "name": "Macedonia",
        "dial_code": "+389",
        "code": "MK",
        "currency": "MKD"
    },
    {
        "name": "Madagascar",
        "dial_code": "+261",
        "code": "MG",
        "currency": "MGA"
    },
    {
        "name": "Malawi",
        "dial_code": "+265",
        "code": "MW",
        "currency": "MWK"
    },
    {
        "name": "Malaysia",
        "dial_code": "+60",
        "code": "MY",
        "currency": "MYR"
    },
    {
        "name": "Maldives",
        "dial_code": "+960",
        "code": "MV",
        "currency": "MVR"
    },
    {
        "name": "Mali",
        "dial_code": "+223",
        "code": "ML",
        "currency": "XOF"
    },
    {
        "name": "Malta",
        "dial_code": "+356",
        "code": "MT",
        "currency": "EUR"
    },
    {
        "name": "Marshall Islands",
        "dial_code": "+692",
        "code": "MH",
        "currency": "USD"
    },
    {
        "name": "Martinique",
        "dial_code": "+596",
        "code": "MQ",
        "currency": "EUR"
    },
    {
        "name": "Mauritania",
        "dial_code": "+222",
        "code": "MR",
        "currency": "MRO"
    },
    {
        "name": "Mauritius",
        "dial_code": "+230",
        "code": "MU",
        "currency": "MUR"
    },
    {
        "name": "Mayotte",
        "dial_code": "+262",
        "code": "YT",
        "currency": "EUR"
    },
    {
        "name": "Mexico",
        "dial_code": "+52",
        "code": "MX",
        "currency": "MXN"
    },
    {
        "name": "Micronesia, Federated States of Micronesia",
        "dial_code": "+691",
        "code": "FM",
        "currency": "USD"
    },
    {
        "name": "Moldova",
        "dial_code": "+373",
        "code": "MD",
        "currency": "MDL"
    },
    {
        "name": "Monaco",
        "dial_code": "+377",
        "code": "MC",
        "currency": "EUR"
    },
    {
        "name": "Mongolia",
        "dial_code": "+976",
        "code": "MN",
        "currency": "MNT"
    },
    {
        "name": "Montenegro",
        "dial_code": "+382",
        "code": "ME",
        "currency": "EUR"
    },
    {
        "name": "Montserrat",
        "dial_code": "+1664",
        "code": "MS",
        "currency": "XCD"
    },
    {
        "name": "Morocco",
        "dial_code": "+212",
        "code": "MA",
        "currency": "MAD"
    },
    {
        "name": "Mozambique",
        "dial_code": "+258",
        "code": "MZ",
        "currency": "MZN"
    },
    {
        "name": "Myanmar",
        "dial_code": "+95",
        "code": "MM",
        "currency": "MMK"
    }
,

]
"""
    
    
    static let BUSINESS_TYPE = [
        "Agriculture and Mining",
        "Arts and Entertainment",
        "Automotive",
        "Beauty and Cosmetics",
        "Biotechnology",
        "Construction",
        "Consulting",
        "Education",
        "Education and Training",
        "Electronics",
        "Energy",
        "Environmental Services",
        "Fashion and Apparel",
        "Finance and Insurance",
        "Food and Beverage",
        "Health and Wellness",
        "Healthcare",
        "Hospitality and Tourism",
        "Information Technology",
        "Legal Services",
        "Logistics",
        "Manufacturing",
        "Marketing and Advertising",
        "Media",
        "Non-Profit",
        "Personal Services",
        "Pharmaceuticals",
        "Professional Services",
        "Publishing",
        "Public Sector",
        "Real Estate",
        "Recreation and Leisure",
        "Retail",
        "Scientific Services",
        "Security Services",
        "Software Development",
        "Technical Services",
        "Telecommunications",
        "Transportation and Warehousing",
        "Utilities",
        "Wholesale Trade"
    ]
}

