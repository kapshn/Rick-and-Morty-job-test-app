//
//  NetworkService.swift
//  Rick-and-Morty-job-test-app
//
//  Created by Monday MeoW. on 05.05.2021.
//

import Foundation
import Combine

enum HTTPTypes: String {
	case GET = "GET", POST = "POST"
}

protocol NetworkServiceProtocol {
	var cancellables: Set<AnyCancellable> { get set }
	func fetchWithURLRequest<T: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<T, Error>
}

class NetworkService: NetworkServiceProtocol {

	var cancellables = Set<AnyCancellable>()
	private var customDecoder: JSONDecoder!

	init() {
		setCustomDecoder()
	}

	private func setCustomDecoder() {
		let formatter = DateFormatter()

		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

		customDecoder = JSONDecoder()
		customDecoder.dateDecodingStrategy = .formatted(formatter)
	}


	func fetchWithURLRequest<T: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<T, Error> {
		URLSession.shared.dataTaskPublisher(for: urlRequest)
			.mapError({ $0 as Error })
			.flatMap({ result -> AnyPublisher<T, Error> in
			guard let urlResponse = result.response as? HTTPURLResponse, (200...299).contains(urlResponse.statusCode) else {
				return Just(result.data)
					.decode(type: APIError.self, decoder: self.customDecoder).tryMap({ errorModel in
					throw errorModel
				})
					.eraseToAnyPublisher()
			}
			return Just(result.data).decode(type: T.self, decoder: self.customDecoder)
				.eraseToAnyPublisher()
		})
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
}

extension NetworkService {
	func getCharacters(for page: Int, filterByName: String, filterByGender: String, filterByStatus: String) -> Future<GeneralAPIResponse<Character>, APIError> {
		var urlRequest = URLRequest(url:Endpoint.getCharacters(name: filterByName, page: page).url)

		urlRequest.httpMethod = HTTPTypes.GET.rawValue
		let publisher: AnyPublisher<GeneralAPIResponse<Character>, Error> = fetchWithURLRequest(urlRequest)
		return Future { promise in
			publisher.sink { (completion) in
				if case .failure(let error) = completion, let apiError = error as? APIError {
					promise(.failure(apiError))
				}
			} receiveValue: { (responseModel) in
				promise(.success(responseModel))
			}
			.store(in: &self.cancellables)
		}
	}

	func getEpisodes(for page: Int, filterByName: String) -> Future<GeneralAPIResponse<Episode>, APIError> {

		var urlRequest = URLRequest(url:Endpoint.getEpisodes(for: filterByName, page: page).url)

		urlRequest.httpMethod = HTTPTypes.GET.rawValue
		let publisher: AnyPublisher<GeneralAPIResponse<Episode>, Error> = fetchWithURLRequest(urlRequest)
		return Future { promise in
			publisher.sink { (completion) in
				if case .failure(let error) = completion, let apiError = error as? APIError {
					promise(.failure(apiError))
				}
			} receiveValue: { (responseModel) in
				promise(.success(responseModel))
			}
			.store(in: &self.cancellables)
		}
	}

	func getMultipleCharacters(_ characterArray: String) -> Future<[Character], APIError> {
		var urlRequest = URLRequest(url:Endpoint.getMultipleCharacters(charactersArray: characterArray).url)

		urlRequest.httpMethod = HTTPTypes.GET.rawValue
		let publisher: AnyPublisher<[Character], Error> = fetchWithURLRequest(urlRequest)
		return Future { promise in
			publisher.sink { (completion) in
				if case .failure(let error) = completion, let apiError = error as? APIError {
					promise(.failure(apiError))
				}
			} receiveValue: { (responseModel) in
				promise(.success(responseModel))
			}
			.store(in: &self.cancellables)
		}
	}
}

struct APIError: Decodable, Error {
	let errorMessage: String

	enum CodingKeys: String, CodingKey {
		case errorMessage = "error"
	}
}

struct GeneralAPIResponse<T: Decodable>: Decodable {
	let pageInfo: PageInfo
	let results: [T]

	enum CodingKeys: String, CodingKey {
		case pageInfo = "info"
		case results = "results"
	}
}

struct PageInfo: Decodable {
	let itemCount: Int
	let pageCount: Int
	let nextPageURL: String?
	let previousPageURL: String?

	enum CodingKeys: String, CodingKey {
		case itemCount = "count"
		case pageCount = "pages"
		case nextPageURL = "next"
		case previousPageURL = "prev"
	}
}
