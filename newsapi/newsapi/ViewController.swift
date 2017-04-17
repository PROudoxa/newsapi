//
//  ViewController.swift
//  newsapi
//
//  Created by Alex Voronov on 13.04.17.
//  Copyright © 2017 Alex&V. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SourceDidSelected {

    
    @IBOutlet weak var tableView: UITableView!
    
    var articles: [Article]? = []
    var sourceName: String = "techcrunch"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchArticles()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMenu" {
            let menuVC: MenuManagerViewController = segue.destination as! MenuManagerViewController
            menuVC.delegate = self
        }
    }
    
    func userDidSelectSource(sourceId: String) {
        sourceName = sourceId
        //sourceName = "al-jazeera-english"
        fetchArticles()
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
                         let title = articleFromJson["title"] as? String
                            let author = articleFromJson["author"] as? String
                            let descr = articleFromJson["description"] as? String
                            let url = articleFromJson["url"] as? String
                            let urlToImage = articleFromJson["urlToImage"] as? String
                        
                            article.author = author
                            article.descr = descr
                            article.url = url
                            article.title = title
                            article.imageUrl = urlToImage
                            
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
        cell.titleLabel.text = self.articles?[indexPath.item].title
        //cell.imageArticleView.backgroundColor = UIColor.lightGray
        cell.descriptionLabel.text = self.articles?[indexPath.item].descr
        cell.authorLabel.text = self.articles?[indexPath.item].author
        
        if let imageUrl = self.articles?[indexPath.item].imageUrl! {
            cell.imageArticleView.downloadImage(from: (imageUrl))
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
        print("menuTapped")
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








