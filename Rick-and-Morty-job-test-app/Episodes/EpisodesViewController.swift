//
//  EpisodesViewController.swift
//  Rick-and-Morty-job-test-app
//
//  Created by Monday MeoW. on 05.05.2021.
//

import UIKit
import Combine

class EpisodesViewController: UIViewController {
	//UI Variables
	private var tableView = UITableView(frame: .zero, style: .insetGrouped)
	//Variables
	private var dataSource: UITableViewDiffableDataSource<Section, Episode>!
	private var cancellables = Set<AnyCancellable>()
	private var episodesViewModel = EpisodesViewModel()


	override func viewDidLoad() {
		super.viewDidLoad()
		configureNavBar()
		configureTableView()
		configureDataSource()
		setViewModelListeners()
		episodesViewModel.getEpisodes()
	}

	private func configureNavBar() {
		title = "Episodes"
	}

	private func setViewModelListeners() {
		Publishers.CombineLatest(episodesViewModel.isFirstLoadingPageSubject, episodesViewModel.episodesSubject).sink {[weak self] (isLoading, episodes) in
			if isLoading {
				self?.tableView.setLoading()
			} else {
				self?.tableView.restore()
				self?.createSnapshot(from: episodes)
				if episodes.isEmpty {
					self?.tableView.setEmptyMessage(message: "No episode found")
				} else {
					self?.tableView.restore()
				}
			}
		}
		.store(in: &cancellables)
	}

}

// MARK: - Table View Data Source Configurations
extension EpisodesViewController: UITableViewDelegate {

	fileprivate enum Section {
		case main
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let currentEpisode = episodesViewModel.episodesSubject.value[indexPath.row]
		let episodeDetailVC = EpisodeDetailViewController(episode: currentEpisode)

		navigationController?.pushViewController(episodeDetailVC, animated: true)
	}

	private func configureTableView(){
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.delegate = self
		tableView.allowsSelection = true
		tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
		view.addSubview(tableView)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}

	private func configureDataSource(){
		dataSource = UITableViewDiffableDataSource<Section, Episode>(tableView: tableView) {(tableView, indexPath, episodeModel) -> UITableViewCell? in
			let cell = UITableViewCell()
			cell.textLabel?.numberOfLines = 2
			cell.textLabel?.text = "\(episodeModel.episodeCode) - \(episodeModel.name)"
			cell.textLabel?.textColor = .black
			return cell
		}
	}

	private func createSnapshot(from addedEpisodes: [Episode]) {
		var snapshot = NSDiffableDataSourceSnapshot<Section, Episode>()
		snapshot.appendSections([.main])
		snapshot.appendItems(addedEpisodes)
		dataSource.apply(snapshot, animatingDifferences: true)
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let position = scrollView.contentOffset.y
		let tableViewContentSizeHeight = tableView.contentSize.height
		let scrollViewHeight = scrollView.frame.size.height

		if position > (tableViewContentSizeHeight - 100 - scrollViewHeight) {
			episodesViewModel.getEpisodes()
		}
	}
}

// MARK: - EXTENSION

extension UITableView {
	func setLoading(){
		let activityIndicatorView = UIActivityIndicatorView(style: .medium)
		activityIndicatorView.color = .cyan
		self.backgroundView = activityIndicatorView
		activityIndicatorView.startAnimating()
		self.separatorStyle = .none
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
		self.separatorStyle = .none
	}

	func restore() {
		self.backgroundView = nil
		self.separatorStyle = .singleLine
	}
}
