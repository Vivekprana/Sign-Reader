//
//  ViewController_popUp.swift
//  Sign Reader
//
//  Created by Vivek Pranavamurthi on 6/27/21.
//

import UIKit

class ViewController_popUp: UIViewController {

    @IBOutlet weak var textPanel: UITextView!
    @IBOutlet weak var closeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set text view parameters
        textPanel.layer.cornerRadius = 50.0

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closePanel(_ sender: Any) {

        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
