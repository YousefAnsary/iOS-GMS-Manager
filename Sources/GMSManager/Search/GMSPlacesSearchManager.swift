//
//  GMSPlacesSearchManager.swift
//  
//
//  Created by Youssef El-Ansary on 29/10/2022.
//

import GooglePlaces

public typealias GMSSearchPrediction = GMSAutocompletePrediction
public typealias GMSSearchResult = GMSPlace

public class GMSPlacesSearchService {
    
    private let placesClient: GMSPlacesClient
    private let debounceInterval: Double
    private var searchTask: DispatchWorkItem?
    
    public init(debounceInterval: Double) {
        self.placesClient = GMSPlacesClient()
        self.debounceInterval = debounceInterval
    }
    
    public func search(for query: String,
                       restrictingToCountries countries: [String]? = nil,
                       completion: @escaping (Result<[GMSSearchPrediction], Error>) -> Void) {
        self.searchTask?.cancel()
        self.searchTask = DispatchWorkItem(block: { [weak self] in
            self?.sendSearchRequest(for: query,
                                    restrictingToCountries: countries,
                                    completion: completion)
        })
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + self.debounceInterval,
                                                             execute: searchTask!)
    }
    
    public func fetchDetails(forPlace place: GMSSearchPrediction,
                             completion: @escaping (Result<GMSSearchResult, Error>) -> Void) {
        self.placesClient.lookUpPlaceID(place.placeID) { (place, error) in
            guard let place = place,
                  error == nil else {
                completion(.failure(error ?? GMSManagerUnknownError()))
                return
            }
            completion(.success(place))
        }
    }
    
    private func sendSearchRequest(for query: String,
                                   restrictingToCountries countries: [String]? = nil,
                                   completion: @escaping (Result<[GMSSearchPrediction], Error>) -> Void) {
        let token = GMSAutocompleteSessionToken()
        let filter = GMSAutocompleteFilter()
        filter.countries = countries
        self.placesClient.findAutocompletePredictions(fromQuery: query,
                                                      filter: filter,
                                                      sessionToken: token,
                                                      callback: { results, error in
            guard let results = results,
                  error == nil else {
                completion(.failure(error ?? GMSManagerUnknownError()))
                return
            }
            completion(.success(results))
        })
    }
}
