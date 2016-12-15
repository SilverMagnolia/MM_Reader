
//  mmReader
//
//  Created by 박종호 on 2016. 12. 15..
//  Copyright © 2016년 박종호. All rights reserved.
//

import UIKit

class FullListNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if checkConnectionToServer() {
            
            
        }
        else {
            
            // show a message "connect to network"
            
            let viewController = UIViewController()
            let view = UIView()
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            
            label.text = "connect to network"
            viewController.view = view
            view.addSubview(label)
            
            var constraint =
                NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0)
            view.addConstraint(constraint)
            
            constraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
            view.addConstraint(constraint)
            
        }

        // Do any additional setup after loading the view.
    }
    
    private func checkConnectionToServer() -> Bool{
        let isNetworkConnected = false
        
        return isNetworkConnected
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
