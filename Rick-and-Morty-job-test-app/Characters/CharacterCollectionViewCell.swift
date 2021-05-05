//
//  CharacterCollectionViewCell.swift
//  Rick-and-Morty-job-test-app
//
//  Created by Monday MeoW. on 05.05.2021.
//

import Foundation
import UIKit
import SDWebImage

class CharacterCollectionViewCell: UICollectionViewCell {
	static let reuseIdentifier: String = "CharacterViewCell"

	var characterImageView = UIImageView()
	var nameLabel = UILabel()


	override init(frame: CGRect) {
		super.init(frame: frame)

		configureCell()
	}

	private func configureCell(){
		contentView.layer.cornerRadius = 10.0
		contentView.backgroundColor = .cyan

		nameLabel.font = .preferredFont(forTextStyle: .subheadline)
		nameLabel.adjustsFontSizeToFitWidth = true
		nameLabel.lineBreakMode = .byTruncatingTail
		nameLabel.textColor = .black

		characterImageView.layer.masksToBounds = true
		characterImageView.layer.cornerRadius = 10.0
		characterImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray


		addSubview(characterImageView)
		addSubview(nameLabel)

		configureAutoLayoutConstraints()
	}

	private func configureAutoLayoutConstraints() {
		let padding: CGFloat = 8

		characterImageView.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			characterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
			characterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
			characterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
			characterImageView.heightAnchor.constraint(equalTo: characterImageView.widthAnchor, constant: -50),

			nameLabel.topAnchor.constraint(equalTo: characterImageView.bottomAnchor, constant: padding),
			nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
			nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
			nameLabel.heightAnchor.constraint(equalToConstant: 20)
		])
	}

	func set(with character: Character) {
		guard let imageURL = URL(string: character.imageURL) else { return }
		characterImageView.sd_setImage(with: imageURL)
		characterImageView.contentMode = UIView.ContentMode.scaleAspectFill
		nameLabel.text = character.name
	}

	required init?(coder: NSCoder) {
		fatalError("something wrong goes at characterCollectionViewCell")
	}
}
