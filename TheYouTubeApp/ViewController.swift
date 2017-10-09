//
//  ViewController.swift
//  TheYouTubeApp
//
//  Created by Saiteja Alle on 10/7/17.
//  Copyright © 2017 Saiteja Alle. All rights reserved.
//

import UIKit
import SDWebImage

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var googleAccountButton: UIBarButtonItem!
    @IBOutlet weak var youtubeCollectionView: UICollectionView!
  
    
    var searchController:UISearchController!
    var shouldShowSearchResults = false
    let arrVideos = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        getTopVideosFromYoutube()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = youtubeCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = UIColor.red
        cell.layer.cornerRadius = 20
        
        let videoDetails = arrVideos[indexPath.row] as! [String: Any]
        let videoImageView = cell.viewWithTag(1) as! UIImageView
        videoImageView.sd_setImage(with: URL.init(string: (videoDetails["imageUrl"] as? String)!), completed: nil)
        return cell
    }
    
    func getTopVideosFromYoutube() {
        
        APIFetcher().getTopVideos("", false) { (videosArray, succses, nextpageToken) in
            if succses == true {
                print(videosArray)
                self.arrVideos.addObjects(from: videosArray)
                self.youtubeCollectionView.reloadData()
            }
        }
        
    }
    
    func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        // Place the search bar view to the tableview headerview.
        self.navigationItem.searchController = searchController
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        youtubeCollectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        youtubeCollectionView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        youtubeCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            youtubeCollectionView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == "" {
            self.arrVideos.removeAllObjects()
            self.youtubeCollectionView.reloadData()
            return
        }else if searchText.characters.count > 1 {
            self.arrVideos.removeAllObjects()
            self.searchYouttubeVideoData(searchText: searchText)
        }else{
            self.arrVideos.removeAllObjects()
            self.youtubeCollectionView.reloadData()
        }
        
    }
    
    func searchYouttubeVideoData(searchText:String) -> Void {
        
        APIFetcher().getVideoWithTextSearch(searchText, "", completion: { (videosArray, succses, nextpageToken) in
            if(succses == true){
                self.arrVideos.addObjects(from: videosArray)
                if(self.arrVideos.count ==  0){
                    
                }else{
                    self.youtubeCollectionView.reloadData()
                }
            }
        })
        
    }


}

