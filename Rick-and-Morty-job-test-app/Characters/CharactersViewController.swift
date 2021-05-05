//
//  CharactersViewController.swift
//  Rick-and-Morty-job-test-app
//
//  Created by Monday MeoW. on 04.05.2021.
//
import UIKit
import Combine

class CharactersViewController: UIViewController {
	//UI Variable
	private var collectionView: UICollectionView!
	private let searchController = UISearchController()
	//Variables
	private var dataSource: UICollectionViewDiffableDataSource<Section, Character>!
	private var cancellables = Set<AnyCancellable>()
	private var charactersViewModel = CharactersViewModel()

	override func viewDidLoad() {
		super.viewDidLoad()
		configureNavBar()
		configureSearchController()
		setupCollectionView()
		configureDataSource()
		setViewModelListeners()
		setSearchControllerListeners()
		charactersViewModel.getCharacters()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}

	private func configureNavBar() {
		navigationItem.searchController = searchController
		title = "Characters"
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
extension CharactersViewController: UICollectionViewDelegate {
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
			charactersViewModel.getCharacters()
		}
	}


}

// MARK: - Search bar methods
extension CharactersViewController: UISearchBarDelegate {
	private func configureSearchController(){
		searchController.searchBar.delegate = self
		searchController.searchBar.placeholder = "Search a Character"
		searchController.obscuresBackgroundDuringPresentation = false
	}

	private func setSearchControllerListeners(){
		NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: searchController.searchBar.searchTextField)
			.map {
				($0.object as! UISearchTextField).text
			}
			.debounce(for: 0.5, scheduler: DispatchQueue.main)
			.removeDuplicates()
			.sink {[weak self] (searchQuery) in
				self?.charactersViewModel.isFirstLoadingPageSubject.value = true
				self?.getCharactersBySearchQuery(searchQuery: searchQuery ?? "")
			}
			.store(in: &cancellables)
	}

	private func getCharactersBySearchQuery(searchQuery: String) {
		charactersViewModel.currentSearchQuery = searchQuery
		charactersViewModel.canLoadMorePages = true
		charactersViewModel.currentPage = 1
		charactersViewModel.getCharacters()
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		if charactersViewModel.currentSearchQuery != "" {
			getCharactersBySearchQuery(searchQuery: "")
		}
	}
}

// MARK: - EXTENSION

extension UICollectionView {
	func setLoading(){
		let activityIndicatorView = UIActivityIndicatorView(style: .medium)
		activityIndicatorView.color = .cyan
		self.backgroundView = activityIndicatorView
		activityIndicatorView.startAnimating()
	}

	func setEmptyMessage(message: String) {
		let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
		messageLabel.text = message
		messageLabel.textColor = .systemGray2
		messageLabel.numberOfLines = 0
		messageLabel.textAlignment = .center
		messageLabel.font = UIFont.preferredFont(forTextStyle: .title2)
		messageLabel.sizeToFit()

		self.backgroundView = messageLabel

	}

	func restore() {
		self.backgroundView = nil
	}
}
