//
//  FilterItemTableViewCell.swift
//  Zilando
//
//  Created by Le, Triet on 30.12.2020.
//

import SnapKit
import UIKit
import Combine

class FilterItemTableViewCell: UITableViewCell {

    // MARK: - Dependencies
    var item: FilterItemTableViewCell.UIModel? {
        didSet {
            configUI()
        }
    }

    // MARK: - UI Properties
    private lazy var filterItemLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.numberOfLines = 1
        label.textColor = .black
        return label
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

    // MARK: - Private methods
    private func setupView() {
        contentView.addSubview(filterItemLabel)
        setConstraints()
    }

    private func setConstraints() {
        filterItemLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.bottom.trailing.equalToSuperview().offset(-8)
        }
    }

    private func configUI() {
        guard let item = item else { return }
        filterItemLabel.text = item.item
        filterItemLabel.textColor = item.isChosen ? .orange : .black
    }

}

extension FilterItemTableViewCell {
    struct UIModel {
        let item: String
        let isChosen: Bool
    }
}
