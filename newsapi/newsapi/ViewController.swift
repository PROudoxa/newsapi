//
//  ViewController.swift
//  newsapi
//
//  Created by Alex Voronov on 13.04.17.
//  Copyright © 2017 Alex&V. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleCell
        cell.titleLabel.text = "title will be here"
        cell.imageArticleView.backgroundColor = UIColor.lightGray
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}

