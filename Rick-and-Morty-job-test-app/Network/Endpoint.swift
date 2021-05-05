//
//  Endpoint.swift
//  Rick-and-Morty-job-test-app
//
//  Created by Monday MeoW. on 05.05.2021.
//

import Foundation

struct Endpoint {
	var path: String
	var queryItems: [URLQueryItem] = []
}

extension Endpoint {
	var url: URL {
		var components = URLComponents()
		components.scheme = "https"
		components.host = "rickandmortyapi.com"
		components.path = "/" + path
		components.queryItems = queryItems

		guard let url = components.url else {
			preconditionFailure(
				"Invalid URL components: \(components)"
			)
		}

		return url
	}
}

extension Endpoint {
	static func getEpisodes(for name: String, page: Int) -> Self {
		Endpoint(
			path: "/api/episode/",
			queryItems: [URLQueryItem(name: "page", value: String(page)),
						 URLQueryItem(name: "name", value: name)]
		)
	}
	static func getCharacters(name: String, page: Int) -> Self {
		Endpoint(
			path: "/api/character/",
			queryItems: [
				URLQueryItem(name: "page", value: String(page)),
				URLQueryItem(name: "name", value: name)
			]
		)
	}
}
