// Nelly Shieh
// nichunsh@usc.edu
//
//  ResultsTableViewController.swift
//  MappIt
//
//  Created by Nelly Shieh on 4/15/20.
//  Copyright © 2020 Nelly Shieh. All rights reserved.
//

import UIKit

class ResultsTableViewController: UITableViewController {

    @IBOutlet weak var resultsTVC: UITableView!
    
    private let searchEvents = TMEventModel.sharedInstance
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchEvents.numberOfTMEvents() + 1
    }

    // set up table cells, last cell is for reloading more events
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < searchEvents.numberOfTMEvents(){
            let cell = resultsTVC.dequeueReusableCell(withIdentifier: "Event", for: indexPath) as! EventTableViewCell
            
            if let event = searchEvents.tmEvent(at: indexPath.row){
                var url: URL?
                var imgs: [TMImages] = []
                cell.eventNameLabel.text = event.name
                
                let date: String
                let time: String
                
                if let dateTime = event.dates.start.dateTime {
                    let dT = dateTime.UTCTolocal()
                    date = dT.localToDate()
                    time = dT.localToTime()
                    cell.eventDateTimeLabel.textColor = UIColor.black
                } else {
                    date = event.dates.start.localDate
                    if let t = event.dates.start.localTime {
                        time = t
                    } else {
                        time = "--"
                    }
                    
                    cell.eventDateTimeLabel.textColor = UIColor.systemPink
                }
                       
                cell.eventDateTimeLabel.text = "\(date) | \(time)"
                cell.eventImageView.image = #imageLiteral(resourceName: "default")
                
                // custom image if possible
                for img in event.images{
                    if let ratio = img.ratio {
                        if ratio == "4_3" {
                            url = URL(string:"\(img.url)")
                            imgs.append(img)
                        }
                    }
                }
                if let link = url{
                    let data = try? Data(contentsOf: link)
                    if let imgdata = data{
                        cell.eventImageView.image = UIImage(data: imgdata)
                    }
                }
                
                searchEvents.updateTMEventImages(img: imgs, at: indexPath.row)
                
            }
            
            return cell
            
        } else {
            let cell = resultsTVC.dequeueReusableCell(withIdentifier: "Message", for: indexPath)
            
            cell.textLabel?.text = searchEvents.getMessage()
            
            return cell
        }
        
    }
    
    // the last table cell, if it was selected, reloads with more events
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == resultsTVC.numberOfRows(inSection: 0)-1 {
            searchEvents.getMoreEvents { (events) in
                DispatchQueue.main.async{
                    self.resultsTVC.reloadData()
                }
            }
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         //Get the new view controller using segue.destination.
         //Pass the selected object to the new view controller.
        
        
        if let details = segue.destination as? DetailsViewController{
            if segue.identifier == "toDetails" {
                details.selectedEvent = searchEvents.tmEvent(at: resultsTVC.indexPathForSelectedRow!.row)
                details.rBarButton.image = UIImage(systemName: "plus")
                details.rBarButton.tag = 0
                details.fromResults = true
                
            
            }
        }
    }
    

}
