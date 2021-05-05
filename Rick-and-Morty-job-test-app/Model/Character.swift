//
//  Character.swift
//  Rick-and-Morty-job-test-app
//
//  Created by Monday MeoW. on 05.05.2021.
//

import Foundation

struct Character: Decodable, Hashable {
	let uuid = UUID()
	let id: Int
	let name: String
	let imageURL: String
	let created: Date

	enum CodingKeys: String, CodingKey {
		case id = "id"
		case name = "name"
		case imageURL = "image"
		case created = "created"
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(uuid)
	}
}
