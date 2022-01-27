//
//  FeedViewController.swift
//  InstagramClone
//
//  Created by Abdullah Ayan on 26.01.2022.
//

import UIKit
import Firebase
import CoreMedia
import SDWebImage

class FeedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    

    
    @IBOutlet weak var tableView: UITableView!
    
    var userEmailArray = [String]()
    var userCommentArray = [String]()
    var userImageArray = [String]()
    var likeArray = [Int]()
    var documentIDArray = [String]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getDataFromFirestore()
    }
    
    
    func getDataFromFirestore(){
        
        let firestoreDatabase = Firestore.firestore()

        firestoreDatabase.collection("Posts").order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
            } else {
                if snapshot?.isEmpty != true {
                    
                    self.userImageArray.removeAll()
                    self.userCommentArray.removeAll()
                    self.userEmailArray.removeAll()
                    self.likeArray.removeAll()
                    
                    for document in snapshot!.documents{
                        

                        let documentID = document.documentID
                        let likes = document.get("likes") as! Int
                        let postComment = document.get("postComment") as! String
                        let postedBy = document.get("postedBy") as! String
                        let imageUrl = document.get("imageUrl") as! String

                        self.documentIDArray.append(documentID)
                        self.userEmailArray.append(postedBy)
                        self.userCommentArray.append(postComment)
                        self.userImageArray.append(imageUrl)
                        self.likeArray.append(likes)
                        
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userEmailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        
        cell.commentLabel.text = userCommentArray[indexPath.row]
        cell.likeLabel.text = String(likeArray[indexPath.row])
        cell.userEmailLabel.text = userEmailArray[indexPath.row]
        cell.userImageView.sd_setImage(with: URL(string: userImageArray[indexPath.row]))
        cell.documentID = documentIDArray[indexPath.row]
        return cell
    }
    
    
    
    
    
}
