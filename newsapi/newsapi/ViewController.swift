//
//  ViewController.swift
//  newsapi
//
//  Created by Alex Voronov on 13.04.17.
//  Copyright © 2017 Alex&V. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SourceDidSelected {

    var articles: [Article]? = []
    let defaults = UserDefaults.standard

    var sourceName: String = "techcrunch"
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if let sourceNameSaved = defaults.string(forKey: "sourceNameSaved") {
            sourceName = sourceNameSaved
        }
        
        fetchArticles()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMenu" {
            let menuVC: MenuManagerViewController = segue.destination as! MenuManagerViewController
            menuVC.delegate = self
        }
    }
    
    func userDidSelectSource(sourceId: String, lastSourceName: String?) {
        sourceName = sourceId
        navigationItem.title = lastSourceName ?? "News Reader"
        fetchArticles()
        defaults.set(sourceName, forKey: "sourceNameSaved")
    }
    
    func fetchArticles() {
        let urlRequest = URLRequest(url: URL(string: "https://newsapi.org/v1/articles?source=\(sourceName)&sortBy=top&apiKey=bcfdf65e5ef5469fa6508ee3edba275f")!)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print(error ?? "printing error has been failed")
                return
            }
            
            self.articles = [Article]()
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                if let articlesFromJson = json["articles"] as? [[String: AnyObject]] {
                    for articleFromJson in articlesFromJson {
                        let article = Article()
                        
                        article.author = articleFromJson["author"] as? String
                        article.descr = articleFromJson["description"] as? String
                        article.url = articleFromJson["url"] as? String
                        article.title = articleFromJson["title"] as? String
                        article.imageUrl = articleFromJson["urlToImage"] as? String
                            
                        self.articles?.append(article)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleCell
        cell.titleLabel.text = self.articles?[indexPath.item].title ?? ""
        cell.descriptionLabel.text = self.articles?[indexPath.item].descr ?? ""
        cell.authorLabel.text = self.articles?[indexPath.item].author ?? ""
        
        let imageUrl: String? = self.articles?[indexPath.item].imageUrl
        
        if (imageUrl != nil) && (imageUrl != "") {
            cell.imageArticleView.downloadImage(from: (imageUrl)!)
        } else {
            cell.imageArticleView.backgroundColor = UIColor.lightGray
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "web") as! WebviewViewController
        webVC.url = self.articles?[indexPath.item].url
        
        self.present(webVC, animated: true, completion: nil)
    }
    
    @IBAction func menuTapped(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let menuViewController = storyBoard.instantiateViewController(withIdentifier: "menu") as! MenuManagerViewController
        self.present(menuViewController, animated:true, completion:nil)
    }
}



extension UIImageView {
    func downloadImage(from url: String) {
        let urlRequest = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print(error ?? "printing error has been failed")
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}






