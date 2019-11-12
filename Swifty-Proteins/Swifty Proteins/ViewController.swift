//
//  ViewController.swift
//  Swifty Protein
//
//  Created by Kondelelani NEDZINGAHE on 2019/10/24.
//  Copyright © 2019 Kondelelani NEDZINGAHE. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController{
    
    let context = LAContext();
    
    @IBOutlet weak var hiderLabel: UILabel!
    
    @IBAction func LoginButt(_ sender: UIButton) {
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "You need to be authonticated"){
            (success, error) in
            
            if success{
                DispatchQueue.main.async {

                    self.performSegue(withIdentifier: "toLigands", sender: self)
                }
            }else{
                print(error);
            }
        }
    }
    
    func hideButton(){
        hiderLabel.isHidden = true;
    }
    
    
    @IBAction func unWindSeque(segue: UIStoryboardSegue){
        if segue.identifier == "backFromLigands"{
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLigands"{
            let dest = segue.destination as! LigandsViewController;
            dest.title = "Ligands"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
            hideButton();
        }
        else{
            showErrAlert(msg: "This phone doesn't support Touch ID")
        }
    }
    
    func showErrAlert(msg: String){
        let alert = UIAlertController(title: "ERROR", message: msg, preferredStyle: .alert);
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil);
        
        alert.addAction(action);
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil);
        }
    }
}
