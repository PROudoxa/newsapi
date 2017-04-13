//
//  ArticleCell.swift
//  newsapi
//
//  Created by Alex Voronov on 13.04.17.
//  Copyright © 2017 Alex&V. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var imageArticleView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
