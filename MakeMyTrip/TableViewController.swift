//
//  TableViewController.swift
//  MakeMyTrip
//
//  Created by admin on 29/07/18.
//  Copyright © 2018 com.capgemini. All rights reserved.
//

import UIKit
import CoreData

/***
    * Creating protocol for the delegate
    * Ceating didSelectStation function
 ***/

protocol TableViewControllerDelegate: NSObjectProtocol {
    func didSelectStation(tableViewController: TableViewController, selectedStation: String)
}

class TableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    weak var tableViewDelegate: TableViewControllerDelegate!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searching = false
    var searchedCountry = [String]()
    var locations = [String]()
    var selectedLabel = ""
    var appDelegate: AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var context:NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tableView.delegate = self
        self.tableView.dataSource = self
        searchBar.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /***
         * Fetching the source and destination details based on the given title
         ***/
        
        if self.title == "Select Source" {
            let LocationfetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Data")
            if let locations = try? context.fetch(LocationfetchRequest) as? [Data] {
                if let myAllLocations = locations {
                    self.locations.removeAll()
                    for location in myAllLocations {
                        self.locations.append(location.source!)
                    }
                }
            }
            tableView.reloadData()
        }
        else{
            let LocationfetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Data")
            if let locations = try? context.fetch(LocationfetchRequest) as? [Data] {
                if let myAllLocations = locations {
                    self.locations.removeAll()
                    for location in myAllLocations {
                        self.locations.append(location.destination!)
                    }
                }
            }
            tableView.reloadData()
        }
    }
    
    // Defining number of rows to be displayed in the table by using count of the array elements
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedCountry.count
        } else {
            return locations.count
        }
    }
    
    //Assigning cells with the data in the array and returning the cell
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if searching{
            cell.textLabel?.text = self.searchedCountry[indexPath.row]
        }else{
            cell.textLabel?.text = self.locations[indexPath.row]
        }
    
        return cell
    }
    
    /***
        * In table view, didSelectRowAt is used to get the selected cell and assigning to the labels in the ViewController
     ***/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var location = ""
        if searching {
            location = self.searchedCountry[indexPath.row]
        } else {
            location = self.locations[indexPath.row]
        }
        if tableViewDelegate != nil {
            tableViewDelegate.didSelectStation(tableViewController: self, selectedStation: location)
            
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

/***
    * Creating extension for the TableViewController for the search delegate
    * Creating searchBar function and filtering the data
 ***/

extension TableViewController: UISearchBarDelegate {
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            searchedCountry = locations.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
            searching = true
            tableView.reloadData()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searching = false
            searchBar.text = ""
            tableView.reloadData()
        }
        
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
