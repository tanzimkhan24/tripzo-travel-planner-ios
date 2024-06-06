//
//  AttractionModel.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 22/5/2024.
//


import Foundation

func fetchAttractions(for cityName: String, completion: @escaping (Result<[Attraction], Error>) -> Void) {
    let apiKey = "AIzaSyDLpWZCxK62J2vMItzi_yGuyCfMfdFgeeA"
    let urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=attractions+in+\(cityName)&key=\(apiKey)"
    
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
            var attractions: [Attraction] = []
            
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
                
                group.notify(queue: .main) {
                    let attraction = Attraction(
                        id: place.place_id,
                        title: place.name,
                        latitude: place.geometry.location.lat,
                        longitude: place.geometry.location.lng,
                        imageUrl: imageUrl,
                        cityName: cityName
                    )
                    attractions.append(attraction)
                }
            }
            
            group.notify(queue: .main) {
                completion(.success(attractions))
            }
        } catch {
            completion(.failure(error))
        }
    }.resume()
}

func fetchPhotoURL(for photoReference: String, apiKey: String, completion: @escaping (Result<String, Error>) -> Void) {
    let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(apiKey)"
    
    guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
        completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    completion(.success(urlString))
}

struct Attraction: Codable {
    let id: String
    let title: String
    let latitude: Double
    let longitude: Double
    let imageUrl: String?
    let cityName: String
}

struct GooglePlacesResponse: Codable {
    let results: [GooglePlace]
}

struct GooglePlace: Codable {
    let place_id: String
    let name: String
    let geometry: Geometry
    let photos: [Photo]?
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
