//
//  AttractionModel.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 22/5/2024.
//

import Foundation
import CoreLocation

func fetchCoordinates(for cityName: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
    let apiKey = "AIzaSyDLpWZCxK62J2vMItzi_yGuyCfMfdFgeeA"
    let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(cityName)&key=\(apiKey)"
    
    guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
        completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "NoData", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }
        
        do {
            let geocodeResponse = try JSONDecoder().decode(GeocodeResponse.self, from: data)
            if let location = geocodeResponse.results.first?.geometry.location {
                let coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
                completion(.success(coordinate))
            } else {
                completion(.failure(NSError(domain: "NoResults", code: 2, userInfo: [NSLocalizedDescriptionKey: "No results found"])))
            }
        } catch {
            completion(.failure(error))
        }
    }.resume()
}


func fetchAttractions(for cityName: String, completion: @escaping (Result<[Attraction], Error>) -> Void) {
    fetchCoordinates(for: cityName) { result in
        switch result {
        case .success(let coordinate):
            fetchNearbyAttractions(latitude: coordinate.latitude, longitude: coordinate.longitude, cityName: cityName, completion: completion)
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

func fetchNearbyAttractions(latitude: Double, longitude: Double, cityName: String, radius: Int = 5000000, completion: @escaping (Result<[Attraction], Error>) -> Void) {
    let apiKey = "AIzaSyDLpWZCxK62J2vMItzi_yGuyCfMfdFgeeA"
    var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&type=tourist_attraction&key=\(apiKey)"
    var attractions: [Attraction] = []

    func fetchPage(nextPageToken: String? = nil) {
        if let token = nextPageToken {
            urlString += "&pagetoken=\(token)"
        }
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let placesResponse = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)
                let group = DispatchGroup()
                
                for place in placesResponse.results {
                    group.enter()
                    var imageUrl: String? = nil
                    if let photoReference = place.photos?.first?.photo_reference {
                        fetchPhotoURL(for: photoReference, apiKey: apiKey) { result in
                            switch result {
                            case .success(let url):
                                imageUrl = url
                            case .failure(let error):
                                print("Error fetching photo URL: \(error)")
                            }
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                    
                    group.enter()
                    fetchCountryName(for: place.geometry.location) { countryResult in
                        switch countryResult {
                        case .success(let countryName):
                            let attraction = Attraction(
                                id: place.place_id,
                                title: place.name,
                                latitude: place.geometry.location.lat,
                                longitude: place.geometry.location.lng,
                                imageUrl: imageUrl,
                                cityName: cityName,
                                countryName: countryName
                            )
                            attractions.append(attraction)
                        case .failure(let error):
                            print("Error fetching country name: \(error)")
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    if let nextPageToken = placesResponse.next_page_token {
                        fetchPage(nextPageToken: nextPageToken)
                    } else {
                        completion(.success(attractions))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    fetchPage()
}

func fetchPhotoURL(for photoReference: String, apiKey: String, completion: @escaping (Result<String, Error>) -> Void) {
    let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(apiKey)"
    
    guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
        completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    completion(.success(urlString))
}

func fetchCountryName(for location: Location, completion: @escaping (Result<String, Error>) -> Void) {
    let apiKey = "AIzaSyDLpWZCxK62J2vMItzi_yGuyCfMfdFgeeA"
    let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(location.lat),\(location.lng)&key=\(apiKey)"
    
    guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
        completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "NoData", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }
        
        do {
            let geocodeResponse = try JSONDecoder().decode(GeocodeResponse.self, from: data)
            if let country = geocodeResponse.results.first?.address_components.first(where: { $0.types.contains("country") })?.long_name {
                completion(.success(country))
            } else {
                completion(.failure(NSError(domain: "NoCountryFound", code: 2, userInfo: [NSLocalizedDescriptionKey: "No country found"])))
            }
        } catch {
            completion(.failure(error))
        }
    }.resume()
}


struct GeocodeResponse: Codable {
    let results: [GeocodeResult]
}

struct GeocodeResult: Codable {
    let address_components: [AddressComponent]
    let geometry: GeocodeGeometry
}

struct AddressComponent: Codable {
    let long_name: String
    let short_name: String
    let types: [String]
}

struct GeocodeGeometry: Codable {
    let location: GeocodeLocation
}

struct GeocodeLocation: Codable {
    let lat: Double
    let lng: Double
}

// Attraction Model
struct Attraction: Codable {
    let id: String
    let title: String
    let latitude: Double
    let longitude: Double
    let imageUrl: String?
    let cityName: String
    let countryName: String
}

// GooglePlacesResponse and supporting structs
struct GooglePlacesResponse: Codable {
    let results: [GooglePlace]
    let next_page_token: String?
}

struct GooglePlace: Codable {
    let place_id: String
    let name: String
    let geometry: Geometry
    let photos: [Photo]?
    let types: [String]
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct Photo: Codable {
    let photo_reference: String
}
