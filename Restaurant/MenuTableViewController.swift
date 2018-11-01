//
//  MenuTableViewController.swift
//  Restaurant
//
//  Created by Muhammed Sahil on 06/09/18.
//  Copyright © 2018 MDAK. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    let sampleMenuItems = [MenuItem(id: 100, name: "XX", description: "YOLO", price: 25, category: "Yo", imageURL: URL(string: "www.yo.com")!), MenuItem(id: 100, name: "XX", description: "YOLO", price: 25, category: "Yo", imageURL: URL(string: "www.yo.com")!), MenuItem(id: 100, name: "XX", description: "YOLO", price: 25, category: "Yo", imageURL: URL(string: "www.yo.com")!)]
    
    var menuItems: [MenuItem] = []
    var category: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.capitalized
        tableView.rowHeight = 99
        
        //tableView.refreshControl = UIRefreshControl()
        //tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        // try to fetch data from server and update the UI
        MenuController.shared.fetchMenuItems(categoryName: category) { (menuItems) in
            if let menuItems = menuItems {
                self.updateUI(with: menuItems)
            } else {
                // otherwise load sample data
                DispatchQueue.main.async {
                    self.menuItems = self.sampleMenuItems
                    self.navigationItem.title = "Sample \(self.category.capitalized)"
                    self.tableView.reloadData()
                }
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func updateUI(with menuItems: [MenuItem]) {
        DispatchQueue.main.async {
            self.menuItems = menuItems
            self.tableView.reloadData()
        }
    }
    
    @objc func refresh() {
        MenuController.shared.fetchMenuItems(categoryName: category) { (menuItems) in
            if let menuItems = menuItems {
                self.updateUI(with: menuItems)
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                }
            } else {
                // otherwise load sample data
                DispatchQueue.main.async {
                    self.menuItems = self.sampleMenuItems
                    self.navigationItem.title = "Sample \(self.category.capitalized)"
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCellIdentifier", for: indexPath)

        // Configure the cell...
        configure(cell: cell, forItemAt: indexPath)
        return cell
    }
    
    func configure(cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        let menuItem = menuItems[indexPath.row]
        cell.textLabel?.text = menuItem.name
        cell.detailTextLabel?.text = String(format: "$%.2f", menuItem.price)
        
        MenuController.shared.fetchImage(url: menuItem.imageURL) { (image) in
            guard let image = image else {return}
            DispatchQueue.main.async {
                if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath != indexPath {
                    return
                }
                cell.imageView?.image = image
                cell.setNeedsLayout()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ItemDetailSegue" {
            let itemDetailViewController = segue.destination as! ItemDetailViewController

            let selectedMenuItem = menuItems[tableView.indexPathForSelectedRow!.row]
            itemDetailViewController.menuItem = selectedMenuItem
        }
    }

}
