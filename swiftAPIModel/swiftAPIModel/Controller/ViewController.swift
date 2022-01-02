//
//  ViewController.swift
//  Mohammad Dawi

import UIKit
import WebKit

class ViewController: UIViewController,UISearchResultsUpdating,UISearchBarDelegate {
    
    private var delegate: AppDelegate?
    @IBOutlet var tableView: UITableView!
    
    var imageURLs = [URL]()// holds the thumbnails urls of the guardian articles
    var downloadImageOperationQueue: OperationQueue? = OperationQueue()
    var operations = NSMutableDictionary()
    var images = NSMutableDictionary()
    var repos = [Pizza]()// holds the guardian articles we want to list
    var selectedRepo : Pizza?// holds the article that was clicked or selected
    var totalReposCount:Int = 0 // total count of articles returned
    var currentReposCount:Int = 0
    var baseUrl:String = "https://private-anon-b665557f33-pizzaapp.apiary-mock.com/restaurants/restaurantId/menu?category=Pizza&orderBy=rank" // changes automatically
    var currentPage:Int = 1 // implement paging
    var pageCount:Int = 30 // changes automatically
    
    //search bar
    var resultSearchController = UISearchController()
    
    // MARK: Search Bar delegate functions
    func updateSearchResults(for searchController: UISearchController) {
        reload()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        baseUrl = "https://private-anon-b665557f33-pizzaapp.apiary-mock.com/restaurants/restaurantId/menu?category=Pizza&orderBy=rank"
        currentPage = 1
        repos.removeAll()
        self.tableView.reloadData()
        getReposPerPage(pageNum: currentPage)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // to limit network activity, reload half a second after last key press.
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ViewController.reload), object: nil)
        self.perform(#selector(self.reload), with: nil, afterDelay: 0.5)
    }
    
    // reload the data when search text cahnges
    @objc func reload() {
        baseUrl = "https://private-anon-b665557f33-pizzaapp.apiary-mock.com/restaurants/restaurantId/menu?category=Pizza&orderBy=rank"
        currentPage = 1
        repos.removeAll()
        self.tableView.reloadData()
        if(resultSearchController.searchBar.text! != ""){
            getReposPerPage(pageNum: currentPage)
        }
    }
    
    // MARK: Pass wiki "web url for article" to web view in detail view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //resultSearchController.isActive = false
        if let svc = segue.destination as? DetailViewCCViewController {
            svc.wiki = selectedRepo?.wiki//"https://www.istockphoto.com/"
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add search controller as table view header
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.delegate = self;
            tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        //keep old search results when going back from detail view
        self.definesPresentationContext = true
        delegate = UIApplication.shared.delegate as? AppDelegate
        //set the initial url for api call
        /*
        baseUrl = "https://content.guardianapis.com/search?api-key=19a3c46d-c355-40fa-b9b9-5b2893b34c1c&show-fields=starRating,thumbnail"
        */
        baseUrl = "https://private-anon-b665557f33-pizzaapp.apiary-mock.com/restaurants/restaurantId/menu?category=Pizza&orderBy=rank"
        getReposPerPage(pageNum: currentPage)
    }
    
    //MARK: get the list of repositories per page
    func getReposPerPage(pageNum : Int){
        var url:String
        if (pageNum<2){
             url = baseUrl
        }
        else{
            url = baseUrl + "&page=" + "\(pageNum)"
        }
        
        // use singelton API class to access data "facade design pattern"
        LibraryAPI.shared.getRepos(url:url,completion:{(myRepos)  in
            if(myRepos != nil){
                self.totalReposCount = LibraryAPI.shared.getReposTotalCount()
                self.repos.append(contentsOf: myRepos)
                self.currentReposCount = self.repos.count
                self.pageCount=myRepos.count
                self.populateModels2(myRepos.count)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    
    // MARK: Fill the avatars urls
    func populateModels2(_ count: Int) {
        //Simulating initial load of content
        for counter in (repos.count-count)..<(repos.count) {
            //Simulating slow download using large images
            let imageURL = URL(string: repos[counter].thumbnailUrl ?? "https://avatars1.githubusercontent.com/u/1961952?v=4")
            if let imageURL = imageURL {
                imageURLs.append(imageURL)
            }

        }
    }
    
    // MARK: Utilities for lazy loading of articles thumbnails
    func executeDownloadImageOperationBlock(for indexPath: IndexPath?) {
        let url: URL? = imageURLs[indexPath?.row ?? 0]
        let blockOperation = BlockOperation()
        weak var weakBlockOperation: BlockOperation? = blockOperation
        weak var weakSelf = self
        blockOperation.addExecutionBlock({
            if (weakBlockOperation?.isCancelled)! {
                if let url = url {
                    weakSelf?.operations[url] = nil
                }
                return
            }
            var imageData: Data? = nil
            if let url = url {
                imageData = try? Data(contentsOf: url)
            }
            var image: UIImage? = nil
            if let imageData = imageData {
                image = UIImage(data: imageData)
            }
            if let url = url {
                weakSelf?.images[url] = image
            }
            weakSelf?.operations[url!] = nil
            DispatchQueue.main.async(execute: {
                let visibleCellIndexPaths = weakSelf?.tableView.indexPathsForVisibleRows
                if let indexPath = indexPath {
                    if visibleCellIndexPaths!.contains(indexPath) {
                        let cell = weakSelf?.tableView.cellForRow(at: indexPath) as? MainCollectionViewCell
                        cell?.avatar!.image = image
                        cell?.activityIndicator.stopAnimating()
                    }
                }
            })
        })
        downloadImageOperationQueue?.addOperation(blockOperation)
        operations[url!] = blockOperation
        
    }
    func cancelDowloandImageOperationBlock(for indexPath: IndexPath?) {
        
        let imageURL: URL? = imageURLs[indexPath?.row ?? 0]
        if let imageURL = imageURL {
            if (operations[imageURL] != nil) {
                let blockOperation: BlockOperation? = (operations.object(forKey: imageURL) as! BlockOperation)
                blockOperation?.cancel()
                operations[imageURL] = nil
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITabBarDelegate,UITableViewDelegate{
    
    // MARK: <UITableViewDataSourcePrefetching>
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            
            // Updating upcoming CollectionView's data source. Not assiging any direct value
            // as this operation is expensive it is performed on a private queue
            let imageURL: URL? = imageURLs[indexPath.row]
            if let imageURL = imageURL {
                if (images[imageURL] == nil) {
                    executeDownloadImageOperationBlock(for: indexPath)
                    print("Prefetching data for indexPath: \(indexPath)")
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            //Unloading or data load operation cancellations should happend here
            let imageURL: URL? = imageURLs[indexPath.row]
            if let imageURL = imageURL {
                if (operations[imageURL] != nil) {
                    cancelDowloandImageOperationBlock(for: indexPath)
                    print("Unloading data fetch in progress for indexPath: \(indexPath)")
                }
            }
        }

    }
    
    // MARK: <UITableViewDataSource>
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainCollectionViewCell
        cell.repoTitleLabel.text = repos[indexPath.row].name
        cell.repoOwnerLabel.text = repos[indexPath.row].price
        cell.repoDescrpLabel.text = repos[indexPath.row].category
        let imageURL: URL? = imageURLs[indexPath.row]
        if let imageURL = imageURL {
            if (images[imageURL] != nil) {
                cell.avatar?.image = (images[imageURL] as! UIImage)
                cell.activityIndicator.stopAnimating()
            } else {
                executeDownloadImageOperationBlock(for: indexPath)
            }
        }
        if (indexPath.row == repos.count - 1) { // last cell
            currentPage += 1
            if (currentReposCount  < totalReposCount) { // more items to fetch
                getReposPerPage(pageNum: currentPage)
            }
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRepo = repos[indexPath.row]
        self.performSegue(withIdentifier: "webview", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.repos.count
    }
    
    // MARK: <UITableViewDelegate>
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelDowloandImageOperationBlock(for: indexPath)

    }

}

