//
//  CharactersViewModel.swift
//  Rick-and-Morty-job-test-app
//
//  Created by Monday MeoW. on 05.05.2021.
//

import Foundation
import Combine

class CharactersViewModel {

	private var cancellables = Set<AnyCancellable>()
	private var isLoadingPage = false

	let charactersSubject = CurrentValueSubject<[Character], Never>([])
	let isFirstLoadingPageSubject = CurrentValueSubject<Bool, Never>(true)
	var currentSearchQuery = ""
	var currentStatus = ""
	var currentGender = ""
	var currentPage = 1
	var canLoadMorePages = true
	var currentDetailQuery = "1,2"

	lazy private var networkService = NetworkService()

	// MARK: - Get characters from API
	func getCharacters() {
		guard !isLoadingPage && canLoadMorePages else {
			return
		}
		isLoadingPage = true
		networkService.getCharacters(for: currentPage, filterByName: currentSearchQuery, filterByGender: currentGender, filterByStatus: currentStatus).sink {[weak self] (completion) in
			if case .failure(let apiError) = completion {
				self?.charactersSubject.value.removeAll()
				self?.isFirstLoadingPageSubject.value = false
				self?.isLoadingPage = false
				print(apiError.errorMessage)
			}
		} receiveValue: {[weak self] (characterResponseModel) in
			if self?.currentPage == 1 {
				self?.charactersSubject.value.removeAll()
			}
			if characterResponseModel.pageInfo.pageCount == self?.currentPage {
				self?.canLoadMorePages = false
			}
			self?.currentPage += 1
			self?.charactersSubject.value.append(contentsOf: characterResponseModel.results)
			self?.isFirstLoadingPageSubject.value = false
			self?.isLoadingPage = false
		}
		.store(in: &cancellables)
	}

	// MARK: - Get characters from API (Episode Detail)
	func getMultipleCharacters() {
		guard !isLoadingPage && canLoadMorePages else {
			return
		}
		isLoadingPage = true
		networkService.getMultipleCharacters(currentDetailQuery).sink {[weak self] (completion) in
			if case .failure(let apiError) = completion {
				self?.charactersSubject.value.removeAll()
				self?.isFirstLoadingPageSubject.value = false
				self?.isLoadingPage = false
				print(apiError.errorMessage)
			}
		} receiveValue: {[weak self] (characterResponseModel) in
			self?.canLoadMorePages = false
			self?.charactersSubject.value.append(contentsOf: characterResponseModel)
			self?.isFirstLoadingPageSubject.value = false
			self?.isLoadingPage = false
		}
		.store(in: &cancellables)
	}

}
