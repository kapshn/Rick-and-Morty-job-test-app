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
	var favoriteIcon = UIImageView()
	var character = Character(id: 0, name: "empty", imageURL: "empty", created: Date())

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

		//favoriteIcon.image = UIImage(systemName: "star")

		characterImageView.addSubview(favoriteIcon)
		addSubview(characterImageView)
		addSubview(nameLabel)

		configureAutoLayoutConstraints()
	}

	private func configureAutoLayoutConstraints() {
		let padding: CGFloat = 8

		characterImageView.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		favoriteIcon.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			characterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
			characterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
			characterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
			characterImageView.heightAnchor.constraint(equalTo: characterImageView.widthAnchor, constant: -50),

			favoriteIcon.topAnchor.constraint(equalTo: characterImageView.topAnchor, constant: padding),
			favoriteIcon.rightAnchor.constraint(equalTo: characterImageView.rightAnchor, constant: -padding),
			favoriteIcon.widthAnchor.constraint(equalTo: characterImageView.widthAnchor, multiplier: 0.25 ),
			favoriteIcon.heightAnchor.constraint(equalTo: favoriteIcon.widthAnchor),

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
		self.character = character
		changeFavoriteIconState(character)
	}

	func changeFavoriteIconState(_ character: Character) {
		let state = character.getFavoriteState()
		favoriteIcon.image = nil
		if state {
			favoriteIcon.image = UIImage(systemName: "star.fill")

		} else {
			favoriteIcon.image = UIImage(systemName: "star")
		}
		favoriteIcon.setNeedsDisplay()
	}

	required init?(coder: NSCoder) {
		fatalError("something wrong goes at characterCollectionViewCell")
	}
}
