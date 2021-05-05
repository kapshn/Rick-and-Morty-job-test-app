//
//  MainAppTabBarViewController.swift
//  Rick-and-Morty-job-test-app
//
//  Created by Monday MeoW. on 04.05.2021.
//

import UIKit

class MainAppTabBarViewController: UITabBarController {

//	let favoritesVC = UINavigationController(rootViewController: FavoritesViewController())
	let episodesVC = UINavigationController(rootViewController: EpisodesViewController())
	let charactersVC = UINavigationController(rootViewController: CharactersViewController())

	override func viewDidLoad() {
		super.viewDidLoad()
		configureUITabBarItems()
		configureTabBar()
	}

	func configureUITabBarItems(){
		charactersVC.tabBarItem = UITabBarItem(title: "Characters", image: UIImage(systemName: "person.3"), tag: 0)
		episodesVC.tabBarItem = UITabBarItem(title: "Episodes", image: UIImage(systemName: "tv"), tag: 1)
		//		favoritesVC.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "star"), tag: 2)
	}

	func configureTabBar(){
		tabBar.tintColor = UIColor.cyan
		setViewControllers([charactersVC, episodesVC /*, favoritesVC*/], animated: true)
	}

}

