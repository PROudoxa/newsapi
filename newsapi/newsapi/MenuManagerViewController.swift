//
//  MenuManagerViewController.swift
//  newsapi
//
//  Created by Alex Voronov on 14.04.17.
//  Copyright © 2017 Alex&V. All rights reserved.
//

import UIKit

protocol SourceDidSelected {
    func userDidSelectSource(sourceId: String, lastSourceName: String?)
}

class MenuManagerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource {

    var delegate: SourceDidSelected? = nil
    var FetchedSources: [Sources] = []
    var sourcesBase: [Sources] = []
    let defaults = UserDefaults.standard

    var categories: Set<String> = Set<String>()
    var languages: Set<String> = Set<String>()
    var countries: Set<String> = Set<String>()
    
    var languageActiveIndex: Int = 0
    var categoriesPickerActiveIndex: Int = 0
    var countriesPickerActiveIndex: Int = 0

    var languagesArray: [String] = ["all", "en", "de", "fr"]
    var pickerDataSource: [[String]] = [
            ["all", "business", "entertainment", "gaming", "general", "music", "politics", "science-and-nature", "sport", "technology"],
            ["all", "au", "de", "gb", "in", "it", "us"]
        ]
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBAction func goBack(_ sender: Any) {
        savePickerAndSegmentIndexes()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        filterListIsSegmentChanged()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        
        restorePickerAndSegmentIndexes()

        fetchSources()
    }
    
    func fetchSources() {
        let urlRequest = URLRequest(url: URL(string: "https://newsapi.org/v1/sources")!)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print(error ?? "printing error failed")
                return
            }
            
            self.FetchedSources = [Sources]()
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                if let sourcesFromJson = json["sources"] as? [[String: AnyObject]] {
                    for sourceFromJson in sourcesFromJson {
                        
                        let source = Sources()
                        
                        source.category = sourceFromJson["category"] as? String
                        source.language = sourceFromJson["language"] as? String
                        source.country = sourceFromJson["country"] as? String
                        source.name = sourceFromJson["name"] as? String
                        source.id = sourceFromJson["id"] as? String
                        //source.url = sourceFromJson["url"] as? String
                        //source.descriptionSource = sourceFromJson["description"] as? String
                        //source.sortBysAvailable = sourceFromJson["sortBysAvailable"] as? String
                        
                        if source.id != nil {
                            self.FetchedSources.append(source)
                        }
                        
                        if let category = sourceFromJson["category"] as? String {
                            self.categories.insert(category)
                        }
                        if let language = sourceFromJson["language"] as? String {
                            self.languages.insert(language)
                        }
                        if let country = sourceFromJson["country"] as? String {
                            self.countries.insert(country)
                        }
                        
                        var categoriesArray: [String] = ["all"]
                        var countriesArray: [String] = ["all"]
                        var languagesArray: [String] = []
                        
                        for category in self.categories.sorted() {
                            categoriesArray.append(category)
                        }
                        for language in self.languages.sorted() {
                            languagesArray.append(language)
                        }
                        for country in self.countries.sorted() {
                            countriesArray.append(country)
                        }
                        
                        if (self.pickerDataSource[0] != categoriesArray || self.pickerDataSource[1] != countriesArray) {
                            self.pickerDataSource = [categoriesArray, countriesArray]
                            self.pickerView.reloadAllComponents()
                        }
                    }
                }
                self.restoreLastListOfsources()
                
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
    
    // MARK: filters(segment+picker)
    
    func filterListIsSegmentChanged() {
        languageActiveIndex = segmentControl.selectedSegmentIndex
        
        sourcesBase = self.FetchedSources
        if languageActiveIndex != 0 {
            sourcesBase = sourcesBase.filter(){ $0.language == languagesArray[languageActiveIndex]}
        }
        if categoriesPickerActiveIndex != 0 {
            sourcesBase = sourcesBase.filter(){ $0.category == pickerDataSource[0][categoriesPickerActiveIndex] }
        }
        if countriesPickerActiveIndex != 0 {
            sourcesBase = sourcesBase.filter(){ $0.country == pickerDataSource[1][countriesPickerActiveIndex] }
        }
    }
    
    func filterCategoryPickerChanged(row: Int) {
        if row != 0 {
            sourcesBase = sourcesBase.filter(){ $0.category == pickerDataSource[0][row] }
        }
        if (languageActiveIndex != 0) && (languageActiveIndex < languagesArray.count){
            sourcesBase = sourcesBase.filter(){ $0.language == languagesArray[languageActiveIndex] }
        }
        if (countriesPickerActiveIndex != 0) && (countriesPickerActiveIndex < pickerDataSource[1].count) {
            sourcesBase = sourcesBase.filter(){ $0.country == pickerDataSource[1][countriesPickerActiveIndex] }
        }
    }
    
    func filterCountryPickerChanged(row: Int) {
        if row != 0 {
            sourcesBase = sourcesBase.filter(){ $0.country == pickerDataSource[1][row] }
        }
        if (languageActiveIndex != 0) && (languageActiveIndex < languagesArray.count){
            sourcesBase = sourcesBase.filter(){ $0.language == languagesArray[languageActiveIndex] }
        }
        if (categoriesPickerActiveIndex != 0) && (categoriesPickerActiveIndex < pickerDataSource[0].count) {
            sourcesBase = sourcesBase.filter(){ $0.category == pickerDataSource[0][categoriesPickerActiveIndex] }
        }
    }
    
    
    // MARK: tableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listOfSourcesCell", for: indexPath)
        cell.textLabel?.text = sourcesBase[indexPath.item].name ?? "unknown source"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourcesBase.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (delegate != nil) {
            let sourceId: String = self.sourcesBase[indexPath.item].id!
            let lastSourceName: String? = self.sourcesBase[indexPath.item].name!
            delegate?.userDidSelectSource(sourceId: sourceId, lastSourceName: lastSourceName)
    
            savePickerAndSegmentIndexes()
            saveListOfSources()
            self.tableView.reloadData()
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: saving & restoration
    
    func restoreLastListOfsources() {
        let count = self.defaults.integer(forKey: "quantityOfSources")
        let arrnames: [String]? = self.defaults.object(forKey: "lastSourcesList_Names") as! [String]?
        let arrId: [String]? = self.defaults.object(forKey: "lastSourcesList_Id") as! [String]?
        
        if (arrnames != nil) && ((arrnames?.count)! > -1) {
            for k in 0...count-1 {
                self.sourcesBase.append(Sources())
                self.sourcesBase[k].name = arrnames?[k] // shows list(names) of sources which user saw previous time
                self.sourcesBase[k].id = arrId?[k]    // neccessary in case user taps source just after saw saved list
            }
        } else {
            self.sourcesBase = self.FetchedSources
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func restorePickerAndSegmentIndexes() {
        let languageActiveIndexSaved: Int? = defaults.integer(forKey: "languageActiveIndex")
        let categoriesPickerActiveIndexSaved: Int? = defaults.integer(forKey: "categoriesPickerActiveIndex")
        let countriesPickerActiveIndexSaved: Int? = defaults.integer(forKey: "countriesPickerActiveIndex")
        
        if  languageActiveIndexSaved != nil {
            languageActiveIndex = languageActiveIndexSaved!
            segmentControl.selectedSegmentIndex = languageActiveIndex
        }
        if  categoriesPickerActiveIndexSaved != nil {
            categoriesPickerActiveIndex = categoriesPickerActiveIndexSaved!
            pickerView.selectRow(categoriesPickerActiveIndex, inComponent: 0, animated: true)
        }
        if countriesPickerActiveIndexSaved != nil {
            countriesPickerActiveIndex = countriesPickerActiveIndexSaved!
            pickerView.selectRow(countriesPickerActiveIndex, inComponent: 1, animated: true)
        }
    }
    
    func savePickerAndSegmentIndexes() {
        defaults.set(countriesPickerActiveIndex, forKey: "countriesPickerActiveIndex")
        defaults.set(categoriesPickerActiveIndex, forKey: "categoriesPickerActiveIndex")
        defaults.set(languageActiveIndex, forKey: "languageActiveIndex")
    }
    
    func saveListOfSources() {
        var savedNamesList: [String] = []
        var savedId: [String] = []
        
        for elementOfList in sourcesBase {
            savedNamesList.append(elementOfList.name!)
            savedId.append(elementOfList.id!)
        }
        
        defaults.set(savedNamesList.count, forKey: "quantityOfSources")
        defaults.set(savedNamesList, forKey: "lastSourcesList_Names")
        defaults.set(savedId, forKey: "lastSourcesList_Id")
    }
    
    
    // MARK: picker
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
            case 0: return CGFloat(240.0)
            case 1: return CGFloat(40.0)
            default: return (180.0)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[component][row]
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        sourcesBase = self.FetchedSources
        
        if component == 0 { // categories picker
            filterCategoryPickerChanged(row: row)
            categoriesPickerActiveIndex = row
        }
        
        if component == 1 { // countries picker
            filterCountryPickerChanged(row: row)
            countriesPickerActiveIndex = row
        }
        self.tableView.reloadData()
    }
}

