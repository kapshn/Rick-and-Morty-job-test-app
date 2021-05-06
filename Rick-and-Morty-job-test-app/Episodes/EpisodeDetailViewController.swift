//
//  EpisodeDetailViewController.swift
//  Rick-and-Morty-job-test-app
//
//  Created by Monday MeoW. on 05.05.2021.
//

import UIKit
import Combine

class EpisodeDetailViewController: UIViewController {
	//UI Variable
	private var collectionView: UICollectionView!
	//Variables
	private var dataSource: UICollectionViewDiffableDataSource<Section, Character>!
	private var cancellables = Set<AnyCancellable>()
	lazy private var charactersViewModel = CharactersViewModel()

	private var episode: Episode

	init(episode: Episode) {
		self.episode = episode
		super.init(nibName: nil, bundle: nil)

		getCharactersByDetailQuery()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureNavBar()
		setupCollectionView()
		configureDataSource()
		setViewModelListeners()
		charactersViewModel.getMultipleCharacters()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}

	private func configureNavBar() {
		title = "Characters in " + episode.episodeCode
	}

	private func setupCollectionView() {
		collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
		collectionView.delegate = self
		collectionView.backgroundColor = .systemBackground
		collectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: CharacterCollectionViewCell.reuseIdentifier)
		view.addSubview(collectionView)
	}

	private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											   heightDimension: .fractionalWidth(0.45))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)

		let layout = UICollectionViewCompositionalLayout(section: section)
		return layout
	}

	private func setViewModelListeners() {
		Publishers.CombineLatest(charactersViewModel.isFirstLoadingPageSubject, charactersViewModel.charactersSubject).sink {[weak self] (isLoading, characters) in
			if isLoading {
				self?.collectionView.setLoading()
			} else {
				self?.collectionView.restore()
				self?.createSnapshot(from: characters)
				if characters.isEmpty {
					self?.collectionView.setEmptyMessage(message: "No character found")
				} else {
					self?.collectionView.restore()
				}
			}
		}
		.store(in: &cancellables)
	}
}

// MARK: - Collection View Data Source Configurations
extension EpisodeDetailViewController: UICollectionViewDelegate {
	fileprivate enum Section {
		case main
	}

	private func configureDataSource(){
		dataSource = UICollectionViewDiffableDataSource<Section, Character>(collectionView: collectionView) {(collectionView, indexPath, characterModel) -> UICollectionViewCell? in
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterCollectionViewCell.reuseIdentifier, for: indexPath) as? CharacterCollectionViewCell
			cell?.set(with: characterModel)
			return cell
		}
	}

	private func createSnapshot(from addedCharacters: [Character]) {
		var snapshot = NSDiffableDataSourceSnapshot<Section, Character>()
		snapshot.appendSections([.main])
		snapshot.appendItems(addedCharacters)
		dataSource.apply(snapshot, animatingDifferences: true)
	}


	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let position = scrollView.contentOffset.y
		let collectionViewContentSizeHeight = collectionView.contentSize.height
		let scrollViewHeight = scrollView.frame.size.height

		if position > (collectionViewContentSizeHeight - 100 - scrollViewHeight) {
			charactersViewModel.getMultipleCharacters()
		}
	}

	private func getCharacterArray() -> String{
		var characterArray = ""
		let charactersURLFromEpisode = episode.characters
		for characterURL in charactersURLFromEpisode {
			var splitUpCharacterURL = characterURL.split(separator: "/")
			characterArray += splitUpCharacterURL.removeLast() + ","
		}
		if !characterArray.isEmpty {
			characterArray.removeLast()
		}
		return characterArray
	}

	private func getCharactersByDetailQuery() {
		charactersViewModel.currentDetailQuery = getCharacterArray()
		charactersViewModel.canLoadMorePages = true
		charactersViewModel.getMultipleCharacters()
	}
}

// MARK: - EXTENSION
