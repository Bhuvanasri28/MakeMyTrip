//
//  ViewController.swift
//  MakeMyTrip
//
//  Created by admin on 29/07/18.
//  Copyright © 2018 com.capgemini. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
/***
     * Created 2 labels to calculate source and destination
     * Created outlet for those 2 labels
     * Created two variables and initializing with string
     * Created two tags with the Id's given to them in the storyboard for the respective labels
***/
    @IBOutlet weak var sourceField: UILabel!
    @IBOutlet weak var destinationField: UILabel!
    var source = "Enter Source"
    var destination = "Enter Destination"
    var window :UIWindow?
    let sourceViewTagId = 1001
    let destViewTagId = 1002
    
    var appDelegate: AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var context:NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceField.text = source
        destinationField.text = destination
        
        /***
            * Created UserDefaults to access the preload function only once and not to create duplicates
        ***/
        
        let preloaded = UserDefaults.standard.bool(forKey: "ONE_TIME_ACCESS")
        if !preloaded{
            UserDefaults.standard.set(true, forKey: "ONE_TIME_ACCESS")
            preload()
        }
    }
    
    /***
        * Created a preload function
        * In preload function we are fetching the data from Data.csv and creating coreData with the entity "Data"
        * Saving all the data in the coreData that is fetched from the csv file
    ***/
    
    func preload() {
        
        if let locationEntity = NSEntityDescription.entity(forEntityName: "Data", in: context){
            
            let path = Bundle.main.path(forResource: "Data", ofType: "csv")
            let filemgr = FileManager.default
            
            if filemgr.fileExists(atPath: path!) {
                do {
                    
                    let fullText = try String(contentsOfFile: path!)
                    let readings = fullText.components(separatedBy: "\n")
                    let count = readings.count
                    
                    for i in 1..<count{
                        let data = readings[i].components(separatedBy: ",")
                        if let location = NSManagedObject(entity: locationEntity, insertInto: context) as? Data {
                            location.source = data[0]
                            //location.destination = data[1]
                            //location.distance = Int64(data[2])!
                            appDelegate.saveContext()
                        }
                    }
                }
                catch let error as NSError {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    func showDetailsPage(){
        if let mainScene = self.storyboard?.instantiateViewController(withIdentifier: "details") as? DisplayDetailsViewController {
            self.present(mainScene, animated: true, completion: nil)
        }
    }

    /***
        *Created actions for the two outlets for the tap gestures that is given to source and destination in the storyboard
        * Inside the actions we are calling a showTableScene function
    ***/
    
    @IBAction func fromAction(_ sender: UITapGestureRecognizer) {
        showTableScene(label:self.sourceField)
    }
    
    @IBAction func toAction(_ sender: UITapGestureRecognizer) {
        showTableScene(label:self.destinationField)
    }
    
    /***
        * Creating showAlert function for the message alert
        * This function helps us to create messages and displaying the fare
    ***/
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        showDetailsPage()
    }
    
    /***
        * Creating an outlet for the label to select class either first class or second class
    ***/
    @IBOutlet weak var selectClass: UILabel!
    
    /***
        * Creating actions for first and second class buttons
        * Assigning text for the selectClass label based on the action
        * Assigning color for the text and background color in the label based on the action happens
    ***/
    
    @IBAction func firstClass(_ sender: UIButton) {
        self.selectClass.text = "First Class"
        self.selectClass.textColor = UIColor.blue
        self.selectClass.backgroundColor = UIColor.cyan
    }
    
    
    @IBAction func selectDestination(_ sender: UIButton) {
        self.selectClass.text = "Second Class"
        self.selectClass.textColor = UIColor.red
        self.selectClass.backgroundColor = UIColor.darkGray
    }
    
    /***
        * Calculating fare by using the function calculateFare
        * Checking the class and calculating fare according to the selection of class
        * Showing alert by calling showAlert function
    ***/
    
    @IBAction func calculateFare(_ sender: Any) {
        var firstClass:Float
        var secondClass:Float
        let obj = getData(source: self.sourceField.text!)
        if sourceField.text == "Enter Source" && destinationField.text == "Enter Destination" {
            showAlert(message: "Please select Source and destination for your trip")
        }
        else if obj?.destination == self.destinationField.text {
            if self.selectClass.text == "First Class"{
                firstClass = Float((obj?.distance)!) * 2.5
                showAlert(message: "From: \(sourceField.text!) \n To: \(destinationField.text!) \n Selected Class: \(selectClass.text!)\n The FirstClass Fare is \(firstClass)")
            }
            else {
                secondClass = Float((obj?.distance)!) * 1.5
                showAlert(message: "From: \(sourceField.text!) \n To: \(destinationField.text!) \n Selected Class: \(selectClass.text!)\n The FirstClass Fare is \(secondClass)")
            }
        }
        else if(sourceField.text == destinationField.text){
            showAlert(message: "Kindly enter different source and destination")
        }
        else{
            showAlert(message: "No trains are available in this route...!!!!")
        }
    }
    
    /***
     * Fetching and predicating the data from the coreData by source attribute
     ***/
    
    func getData(source: String) -> Data? {
        let dataFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
        dataFetchRequest.predicate = NSPredicate(format: "source == %@", source)
        if let data = try? context.fetch(dataFetchRequest) as? [Data] {
            return data?.first
        }
        return nil
    }
    
    /***
        * Creating a showTableScene() function
        * In the function instatiating storyboard and navigating to the TableViewController
        * Based on the tags assigned we are assigning titles for the tableScene
     ***/
    
    func showTableScene(label:UILabel){
        
        if let tableScene = self.storyboard?.instantiateViewController(withIdentifier: "Table") as? TableViewController {
            tableScene.tableViewDelegate = self
            if(label.tag == 1001){
                tableScene.title = "Select Source"
            }
            if(label.tag == 1002){
                tableScene.title = "Select Destination"
            }
            tableScene.view.tag = label.tag
            let nav = UINavigationController(rootViewController: tableScene)
            self.present(nav, animated: true, completion: nil)
        }
        
    }
}

/***
 * Creating extension for the ViewController and implementing Delegate function i.e; written in the TableViewController
 * Assigning selected source and destination in the tableView for the sourceField and destinationField
 ****/

extension ViewController: TableViewControllerDelegate {
    
    func didSelectStation(tableViewController: TableViewController, selectedStation: String) {
        if tableViewController.view.tag == sourceViewTagId {
            self.sourceField.text = selectedStation
        }
        else if tableViewController.view.tag == destViewTagId {
            self.destinationField.text = selectedStation
        }
    }
}



