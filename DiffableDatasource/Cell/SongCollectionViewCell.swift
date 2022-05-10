//
//  SongCollectionViewCell.swift
//  DiffableDatasource
//
//  Created by JoSoJeong on 2022/05/10.
//

import Foundation
import UIKit
import SnapKit

class SongCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "song-cell-reuse-identifier"
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    var singerLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
}

extension SongCollectionViewCell {
    func configureUI(){
        contentView.addSubview(titleLabel)
        contentView.addSubview(singerLabel)
        
        layer.borderWidth = 1
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        singerLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp_bottomMargin).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.bottom.equalToSuperview().offset(-10)
        }
    }
}
