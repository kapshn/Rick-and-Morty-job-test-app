//
//  FavoritesCharacterViewController.swift
//  Rick-and-Morty-job-test-app
//
//  Created by Monday MeoW. on 10.05.2021.
//
import UIKit
import Combine

class FavoritesCharacterViewController: UIViewController {
	//UI Variable
	private var collectionView: UICollectionView!
	//Variables
	private var dataSource: UICollectionViewDiffableDataSource<Section, Character>!
	private var cancellables = Set<AnyCancellable>()
	lazy private var charactersViewModel = CharactersViewModel()

	init() {
		super.init(nibName: nil, bundle: nil)

		//getCharactersByDetailQuery()
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
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		getCharactersByDetailQuery()
		collectionView.reloadData()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}

	private func configureNavBar() {
		title = "Favourites Characters"
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
extension FavoritesCharacterViewController: UICollectionViewDelegate {
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

	private func getCharacterArray() -> String{
		var characterArray = ""
		for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
			var splitUpKey = key.split(separator: "_")
			if key.contains("Rick_and_Morty_user_defaults") && (value as! Bool)
			{
				characterArray += splitUpKey.removeLast() + ","
			}
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

