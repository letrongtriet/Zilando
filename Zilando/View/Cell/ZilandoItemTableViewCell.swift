//
//  ZilandoItemTableViewCell.swift
//  Zilando
//
//  Created by Le, Triet on 30.12.2020
//

import UIKit
import Combine
import SDWebImage

class ZilandoItemTableViewCell: UITableViewCell {

    // MARK: - Observable
    var favoriteButtonCallback = PassthroughSubject<ZilandoItemTableViewCell.UIModel, Never>()

    // MARK: - Dependencies
    var item: ZilandoItemTableViewCell.UIModel?

    // MARK: - UI Properties
    private lazy var itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private lazy var itemNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .black
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 2
        label.textColor = UIColor.black.withAlphaComponent(0.7)
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.numberOfLines = 1
        label.textColor = UIColor.orange
        return label
    }()

    private lazy var tagLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 1
        label.textColor = UIColor.black
        label.backgroundColor = .white
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()

    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView()

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.backgroundColor = .clear

        stackView.addArrangedSubview(itemNameLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(priceLabel)

        return stackView
    }()

    private lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "NotFavorite"), for: .normal)
        button.setTitle(nil, for: .normal)
        button.addTarget(self, action: #selector(handleFavoriteButtonTapped), for: .touchUpInside)
        button.tintColor = .orange
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()

    // MARK: - Lifecycles
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    // MARK: - Public methods
    func configUI() {
        guard let item = item else { return }

        itemImageView.sd_setImage(with: URL(string: item.item.image), completed: nil)
        itemNameLabel.text = item.item.title
        descriptionLabel.text = item.item.description
        priceLabel.text = item.item.price.priceWithCurrency
        tagLabel.text = item.item.category
        favoriteButton.setImage(item.isFavorite ? UIImage(named: "Favorite") : UIImage(named: "NotFavorite"), for: .normal)
    }

    // MARK: - Private methods
    private func setupView() {
        contentView.addSubview(itemImageView)
        contentView.addSubview(labelsStackView)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(tagLabel)

        setConstraints()
    }

    private func setConstraints() {
        itemImageView.snp.makeConstraints { make in
            make.height.equalTo(140)
            make.width.equalTo(100)
            make.leading.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }

        labelsStackView.snp.makeConstraints { make in
            make.centerY.equalTo(itemImageView.snp.centerY)
            make.leading.equalTo(itemImageView.snp.trailing).offset(12)
            make.trailing.equalTo(favoriteButton.snp.leading).offset(-12)
        }

        favoriteButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalTo(itemImageView.snp.centerY)
        }

        tagLabel.snp.makeConstraints { make in
            make.bottom.equalTo(itemImageView).offset(-8)
            make.leading.equalTo(itemImageView).offset(8)
        }
    }

    @objc private func handleFavoriteButtonTapped() {
        guard let item = item else { return }

        var isFavorite = item.isFavorite
        isFavorite.toggle()
        favoriteButtonCallback.send(ZilandoItemTableViewCell.UIModel(item: item.item, isFavorite: isFavorite))
    }

}

extension ZilandoItemTableViewCell {
    struct UIModel {
        let item: Item
        let isFavorite: Bool
    }
}
