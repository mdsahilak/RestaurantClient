//
//  OrderTableViewController.swift
//  Restaurant
//
//  Created by Muhammed Sahil on 06/09/18.
//  Copyright © 2018 MDAK. All rights reserved.
//

import UIKit

protocol AddToOrderDelegate {
    func added(menuItem: MenuItem)
}

class OrderTableViewController: UITableViewController, AddToOrderDelegate {

    var menuItems = [MenuItem]()
    var orderSucessData: OrderSuccess?

    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = editButtonItem
        tableView.rowHeight = 77
        
        if menuItems.isEmpty {
            submitButton.isEnabled = false
            editButtonItem.isEnabled = false
        } else {
            submitButton.isEnabled = true
            editButtonItem.isEnabled = true
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func added(menuItem: MenuItem) {
        menuItems.append(menuItem)
        let count = menuItems.count
        let indexPath = IndexPath(row: count-1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        updateBadgeNumber()
    }
    
    func updateBadgeNumber() {
        let badgeValue = menuItems.count > 0 ? "\(menuItems.count)" : nil
        navigationController?.tabBarItem.badgeValue = badgeValue
        
        (submitButton.isEnabled, editButtonItem.isEnabled) = menuItems.count > 0 ? (true,true) : (false,false)
    }
    
    // Special code for enabling and disabling confirm button for table number alert
    var action: UIAlertAction? = nil
    var orderingEntityText: String? = nil
    @objc func textChanged(_ textField: UITextField) {
        //print("hoho")
        guard let action = action else {return}
        if let text = textField.text, !text.isEmpty {
            orderingEntityText = text
            action.isEnabled = true
        } else {
            action.isEnabled = false
        }
    }
    
    @IBAction func submitTapped(_ sender: UIBarButtonItem) {
        let orderTotal = menuItems.reduce(0.0) { (result, menuItem) -> Double in
            return result + menuItem.price
        }
        let formattedOrder = String(format: "$%.2f", orderTotal)
        
        let alert = UIAlertController(title: "Confirm Order", message: "You are about to submit your order worth a total of \(formattedOrder). Please enter ordering entity's identifier.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
            self.uploadOrder()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField { (textField) in
            textField.placeholder = "Eg: Greg @Table 13"
            textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
        }
        
        //
        alert.actions.first!.isEnabled = false
        action = alert.actions.first!
        
        present(alert, animated: true, completion: nil)
    }
    
    func uploadOrder() {
        let menuIds = menuItems.map { $0.id }
        self.navigationItem.title = "Pls wait..."
        
        //
        let order = Order(id: nil, orderingEntity: orderingEntityText ?? "X", orderedIds: menuIds)
        MenuController.shared.submitOrder(order: order) { (orderSuccess) in
            DispatchQueue.main.async {
                if let orderSuccess = orderSuccess {
                    self.orderSucessData = orderSuccess
                    self.performSegue(withIdentifier: "ConfirmationSegue", sender: nil)
                } else {
                    let paymentErrorAlert = UIAlertController(title: "Payment Processing Error", message: "Your payment could not be processed. Please check your internet connection or try again later.", preferredStyle: .alert)
                    paymentErrorAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { (action) in
                        self.navigationItem.title = "Order"
                    }))
                    self.navigationItem.title = "Order Failed!"
                    self.present(paymentErrorAlert, animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCellIdentifier", for: indexPath)

        // Configure the cell...
        configure(cell: cell, forItemAt: indexPath)
        
        return cell
    }
    
    func configure(cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        let menuItem = menuItems[indexPath.row]
        cell.textLabel?.text = menuItem.name
        cell.detailTextLabel?.text = String(format: "$%.2f", menuItem.price)
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            menuItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateBadgeNumber()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 77.0
    }
    
    
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
        if segue.identifier == "ConfirmationSegue" {
            let orderConfirmationViewController = segue.destination as! OrderConfirmationViewController
            orderConfirmationViewController.orderSuccessInfo = orderSucessData
        }
        if segue.identifier == "OrderItemDetailViewSegue" {
            let orderItemDetailViewController = segue.destination as! ItemDetailViewController
            
            let selectedMenuItem = menuItems[tableView.indexPathForSelectedRow!.row]
            orderItemDetailViewController.menuItem = selectedMenuItem
            orderItemDetailViewController.isInOrderAgainMode = true
        }
    }
    
    @IBAction func unwindToOrderList(segue: UIStoryboardSegue) {
        if segue.identifier == "DismissConfirmation" {
            menuItems.removeAll()
            tableView.reloadData()
            updateBadgeNumber()
            self.navigationItem.title = "Order"
        }
    }

}
