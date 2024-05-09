// Copyright © 2023 SOFTMENT. All rights reserved.

import Foundation

// MARK: - SongModel

class SongModel: Codable {
    // MARK: Lifecycle

    init(status: String?, message: JSONNull?, data: DataClass?) {
        self.status = status
        self.message = message
        self.data = data
    }

    // MARK: Internal

    var status: String?
    var message: JSONNull?
    var data: DataClass?
}

// MARK: - DataClass

class DataClass: Codable {
    // MARK: Lifecycle

    init(total: Int?, start: Int?, results: [Result]?) {
        self.total = total
        self.start = start
        self.results = results
    }

    // MARK: Internal

    var total, start: Int?
    var results: [Result]?
}

// MARK: - Result

class Result: Codable {
    // MARK: Lifecycle

    init(
        id: String?,
        name: String?,
        type: String?,
        album: Album?,
        year: String?,
        releaseDate: JSONNull?,
        duration: String?,
        label: String?,
        primaryArtists: String?,
        primaryArtistsID: String?,
        featuredArtists: String?,
        featuredArtistsID: String?,
        explicitContent: Int?,
        playCount: String?,
        language: String?,
        hasLyrics: String?,
        url: String?,
        copyright: String?,
        image: [DownloadURL]?,
        downloadURL: [DownloadURL]?
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.album = album
        self.year = year
        self.releaseDate = releaseDate
        self.duration = duration
        self.label = label
        self.primaryArtists = primaryArtists
        self.primaryArtistsID = primaryArtistsID
        self.featuredArtists = featuredArtists
        self.featuredArtistsID = featuredArtistsID
        self.explicitContent = explicitContent
        self.playCount = playCount
        self.language = language
        self.hasLyrics = hasLyrics
        self.url = url
        self.copyright = copyright
        self.image = image
        self.downloadURL = downloadURL
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case album
        case year
        case releaseDate
        case duration
        case label
        case primaryArtists
        case primaryArtistsID = "primaryArtistsId"
        case featuredArtists
        case featuredArtistsID = "featuredArtistsId"
        case explicitContent, playCount, language, hasLyrics, url, copyright, image
        case downloadURL = "downloadUrl"
    }

    var id, name, type: String?
    var album: Album?
    var year: String?
    var releaseDate: JSONNull?
    var duration, label, primaryArtists, primaryArtistsID: String?
    var featuredArtists, featuredArtistsID: String?
    var explicitContent: Int?
    var playCount, language, hasLyrics: String?
    var url: String?
    var copyright: String?
    var image, downloadURL: [DownloadURL]?
}

// MARK: - Album

class Album: Codable {
    // MARK: Lifecycle

    init(id: String?, name: String?, url: String?) {
        self.id = id
        self.name = name
        self.url = url
    }

    // MARK: Internal

    var id, name: String?
    var url: String?
}

// MARK: - DownloadURL

class DownloadURL: Codable {
    // MARK: Lifecycle

    init(quality: String?, link: String?) {
        self.quality = quality
        self.link = link
    }

    // MARK: Internal

    var quality: String?
    var link: String?
}

// MARK: - JSONNull

class JSONNull: Codable, Hashable {
    // MARK: Lifecycle

    init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(
                JSONNull.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull")
            )
        }
    }

    // MARK: Internal

    var hashValue: Int {
        0
    }

    static func == (_: JSONNull, _: JSONNull) -> Bool {
        true
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
