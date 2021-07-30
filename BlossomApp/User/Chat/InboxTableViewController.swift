//
//  InboxTableViewController.swift
//  BlossomApp
//
//  Created by nim on 30/7/2564 BE.
//

import UIKit

class InboxTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.backgroundColor
        self.title = "Inbox"
        InboxMessage.getMessages()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return InboxMessage.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return InboxMessage.numberOfRowsInSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            cell?.backgroundColor = UIColor.backgroundColor
            cell?.selectionStyle = .none
            cell?.textLabel?.font = FontSize.title.bold()
            cell?.detailTextLabel?.font = FontSize.body.regular()
        }
        
        let message = InboxMessage.objectAtIndexPath(indexPath)
        cell?.textLabel?.text = message.createdAt?.toFormat("d MMM yyyy HH:mm")
        cell?.detailTextLabel?.text = message.message

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = InboxMessage.objectAtIndexPath(indexPath)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let deeplink = message.deeplink, !deeplink.isEmpty{
            appDelegate.deeplinking = Deeplinking.convert(from: URL(string: deeplink))
            appDelegate.handleDeeplinking()
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
}
