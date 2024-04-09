//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController {
    
    // Refer from App Store Connect product id
    var productID = "xyz"
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    var isPurchased: Bool {
        return UserDefaults.standard.bool(forKey: productID)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Adds an observer to the payment queue.
        SKPaymentQueue.default().add(self)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isPurchased ? quotesToShow.count : quotesToShow.count + 1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        var content = cell.defaultContentConfiguration()

        if indexPath.row < quotesToShow.count {
            // Configure the quote cell...
            content.text = quotesToShow[indexPath.row]
            content.textProperties.numberOfLines = 0
            content.textProperties.color = UIColor.black
            cell.accessoryType = .none
        } else if isPurchased, indexPath.row == quotesToShow.count {
            content.text = "Get more quotes 🤓..."
            content.textProperties.color = UIColor(red: 40, green: 170, blue: 192, alpha: 1)
            cell.accessoryType = .disclosureIndicator
        }

        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPurchased, indexPath.row == quotesToShow.count {
            // Get more quotes tapped
            buyPremiumQuotes()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func buyPremiumQuotes() {
        if SKPaymentQueue.canMakePayments() {
            // Can make payments
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {

        }
    }

    func showPremiumQuotes() {
        UserDefaults.standard.setValue(true, forKey: productID)
        quotesToShow.append(contentsOf: premiumQuotes)
        tableView.reloadData()
    }

    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension QuoteTableViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("Transaction Successful")
                showPremiumQuotes()
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                if let error = transaction.error {
                    print("Transaction failed with error: \(error)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                UserDefaults.standard.setValue(false, forKey: productID)
            case .restored:
                print("Transaction Restored")
                showPremiumQuotes()
                SKPaymentQueue.default().finishTransaction(transaction)
                navigationItem.setRightBarButton(nil, animated: true)
            default:
                print("Transaction State: ", transaction.transactionState)
                UserDefaults.standard.setValue(false, forKey: productID)
            }
        }
    }
}
