import Foundation

// MARK: - BookModel
class BookModel: Codable {
    var count: Int?
    var next: String?
    var previous: BookJSONNull?
    var results: [BookResult]?

    init(count: Int?, next: String?, previous: BookJSONNull?, results: [BookResult]?) {
        self.count = count
        self.next = next
        self.previous = previous
        self.results = results
    }
}

// MARK: - BookResult
class BookResult: Codable {
    var id: Int?
    var title: String?
    var authors, translators: [Author]?
    var subjects, bookshelves: [String]?
    var languages: [Language]?
    var copyright: Bool?
    var mediaType: MediaType?
    var formats: Formats?
    var downloadCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, authors, translators, subjects, bookshelves, languages, copyright
        case mediaType = "media_type"
        case formats
        case downloadCount = "download_count"
    }

    init(id: Int?, title: String?, authors: [Author]?, translators: [Author]?, subjects: [String]?, bookshelves: [String]?, languages: [Language]?, copyright: Bool?, mediaType: MediaType?, formats: Formats?, downloadCount: Int?) {
        self.id = id
        self.title = title
        self.authors = authors
        self.translators = translators
        self.subjects = subjects
        self.bookshelves = bookshelves
        self.languages = languages
        self.copyright = copyright
        self.mediaType = mediaType
        self.formats = formats
        self.downloadCount = downloadCount
    }
}

// MARK: - Author
class Author: Codable {
    var name: String?
    var birthYear, deathYear: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case birthYear = "birth_year"
        case deathYear = "death_year"
    }

    init(name: String?, birthYear: Int?, deathYear: Int?) {
        self.name = name
        self.birthYear = birthYear
        self.deathYear = deathYear
    }
}

// MARK: - Formats
class Formats: Codable {
    var textHTML: String?
    var applicationEpubZip: String?
    var applicationXMobipocketEbook: String?
    var applicationRDFXML: String?
    var imageJPEG: String?
    var textPlainCharsetUsASCII: String?
    var applicationOctetStream: String?
    var textHTMLCharsetUTF8: String?
    var textPlainCharsetUTF8: String?
    var textPlainCharsetISO88591: String?
    var textHTMLCharsetISO88591: String?

    enum CodingKeys: String, CodingKey {
        case textHTML = "text/html"
        case applicationEpubZip = "application/epub+zip"
        case applicationXMobipocketEbook = "application/x-mobipocket-ebook"
        case applicationRDFXML = "application/rdf+xml"
        case imageJPEG = "image/jpeg"
        case textPlainCharsetUsASCII = "text/plain; charset=us-ascii"
        case applicationOctetStream = "application/octet-stream"
        case textHTMLCharsetUTF8 = "text/html; charset=utf-8"
        case textPlainCharsetUTF8 = "text/plain; charset=utf-8"
        case textPlainCharsetISO88591 = "text/plain; charset=iso-8859-1"
        case textHTMLCharsetISO88591 = "text/html; charset=iso-8859-1"
    }

    init(textHTML: String?, applicationEpubZip: String?, applicationXMobipocketEbook: String?, applicationRDFXML: String?, imageJPEG: String?, textPlainCharsetUsASCII: String?, applicationOctetStream: String?, textHTMLCharsetUTF8: String?, textPlainCharsetUTF8: String?, textPlainCharsetISO88591: String?, textHTMLCharsetISO88591: String?) {
        self.textHTML = textHTML
        self.applicationEpubZip = applicationEpubZip
        self.applicationXMobipocketEbook = applicationXMobipocketEbook
        self.applicationRDFXML = applicationRDFXML
        self.imageJPEG = imageJPEG
        self.textPlainCharsetUsASCII = textPlainCharsetUsASCII
        self.applicationOctetStream = applicationOctetStream
        self.textHTMLCharsetUTF8 = textHTMLCharsetUTF8
        self.textPlainCharsetUTF8 = textPlainCharsetUTF8
        self.textPlainCharsetISO88591 = textPlainCharsetISO88591
        self.textHTMLCharsetISO88591 = textHTMLCharsetISO88591
    }
}

// MARK: - Language
enum Language: String, Codable {
    case en = "en"
    case es = "es"
    case pt = "pt" // Added Portuguese

    case unknown // Handle unknown values

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(String.self)
        self = Language(rawValue: rawValue ?? "") ?? .unknown
    }
}

// MARK: - MediaType
enum MediaType: String, Codable {
    case text = "Text"
}

// MARK: - BookJSONNull
class BookJSONNull: Codable, Hashable {

    public static func == (lhs: BookJSONNull, rhs: BookJSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(BookJSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for BookJSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
