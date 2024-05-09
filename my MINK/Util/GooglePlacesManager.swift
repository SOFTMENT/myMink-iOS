// Copyright © 2023 SOFTMENT. All rights reserved.

import Foundation
import GooglePlaces

// MARK: - Place

struct Place {
    let name: String?
    let identifier: String?
}

// MARK: - GooglePlacesManager

final class GooglePlacesManager {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    enum PlacesError: Error {
        case failedToFind
        case failedToFindCoordinates
    }

    static let shared = GooglePlacesManager()

    func findPlaces(query: String, completion: @escaping (Swift.Result<[Place], Error>) -> Void) {
        let filter = GMSAutocompleteFilter()

        self.client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { results, error in
            guard let results = results, error == nil else {
                completion(.failure(PlacesError.failedToFind))
                return
            }

            let places: [Place] = results.compactMap { predication in
                Place(name: predication.attributedFullText.string, identifier: predication.placeID)
            }
            completion(.success(places))
        }
    }

    func resolveLocation(
        for place: Place,
        completion: @escaping (Swift.Result<CLLocationCoordinate2D, Error>) -> Void
    ) {
        self.client
            .fetchPlace(
                fromPlaceID: place.identifier!,
                placeFields: .coordinate,
                sessionToken: nil
            ) { googlePlace, error in

                guard let googlePlace = googlePlace, error == nil else {
                    completion(.failure(PlacesError.failedToFindCoordinates))
                    return
                }

                let coordinate = CLLocationCoordinate2D(
                    latitude: googlePlace.coordinate.latitude,
                    longitude: googlePlace.coordinate.longitude
                )

                completion(.success(coordinate))
            }
    }

    // MARK: Private

    private let client = GMSPlacesClient.shared()
}
