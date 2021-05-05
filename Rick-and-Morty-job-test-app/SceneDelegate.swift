//
//  SceneDelegate.swift
//  Rick-and-Morty-job-test-app
//
//  Created by Monday MeoW. on 04.05.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?


	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		window = UIWindow(frame: windowScene.screen.bounds)
		window?.windowScene = windowScene
		window?.rootViewController = MainAppTabBarViewController()
		window?.makeKeyAndVisible()
	}
}

