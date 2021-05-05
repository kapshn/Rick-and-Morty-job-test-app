//
//  Episode.swift
//  Rick-and-Morty-job-test-app
//
//  Created by Monday MeoW. on 05.05.2021.
//

import Foundation

struct Episode: Decodable, Hashable {
	let uuid = UUID()
	let id: Int
	let name: String
	let airDate: String
	let episodeCode: String
	let characters: [String]
	let createdAt: Date

	enum CodingKeys: String, CodingKey {
		case id = "id"
		case name = "name"
		case airDate = "air_date"
		case episodeCode = "episode"
		case characters = "characters"
		case createdAt = "created"
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(uuid)
	}

}
