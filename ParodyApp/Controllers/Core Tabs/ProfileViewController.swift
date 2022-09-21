//
//  ProfileViewController.swift
//  ParodyApp
//
//  Created by Dawson Chen on 6/14/22.
//

import UIKit

class ProfileViewController: UIViewController {

    var user: String?
    var parodies: [Parody]?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = user ?? "unknown"
//        collectionView.dataSource = self
    }

}

//MARK: - UI Collection View Data Source Methods

//extension ProfileViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if let theseParodies = parodies {
//            return theseParodies.count
//        } else {
//            return 0
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let newCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: <#T##String#>, for: <#T##IndexPath#>)
//    }
    
    
//}

//MARK: - Model Manipulation Methods

func loadParodies() {
    
}
