//
//  chosenTeam.swift
//  pokemongo
//
//  Created by Jack Chen on 7/14/16.
//  Copyright © 2016 Angel Lim. All rights reserved.
//

import UIKit

var chosenTeamName = "none"
class chosenTeam: UIViewController {
    
    
    @IBOutlet weak var instinctImage: UIImageView!
    
    @IBOutlet weak var mysticImage: UIImageView!
    
    
    @IBOutlet weak var valorImage: UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    var chosen = false
    
    
    @IBAction func instinctPressed(sender: AnyObject) {
        chosen = true
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("yellow", forKey: "chosenTeam")
        
        print("chose yellow")
        instinctImage.image = UIImage(named: "instinctChosen.png")
        valorImage.image = UIImage(named: "valorNotChosen.png")
        mysticImage.image = UIImage(named: "mysticNotChosen.png")
        self.performSegueWithIdentifier("showMap", sender: nil)
    }
    
    
    @IBAction func valorPressed(sender: AnyObject) {
        chosen = true
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("red", forKey: "chosenTeam")
        instinctImage.image = UIImage(named: "instinctNotChosen.png")
        valorImage.image = UIImage(named: "valorChosen.png")
        mysticImage.image = UIImage(named: "mysticNotChosen.png")
        self.performSegueWithIdentifier("showMap", sender: nil)
    }
    
    @IBAction func mysticPressed(sender: AnyObject) {
        chosen = true
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("blue", forKey: "chosenTeam")
        instinctImage.image = UIImage(named: "instinctNotChosen.png")
        valorImage.image = UIImage(named: "valorNotChosen.png")
        mysticImage.image = UIImage(named: "mysticChosen.png")
        self.performSegueWithIdentifier("showMap", sender: nil)
    }
    
    @IBAction func pressedConfirm(sender: AnyObject) {
        if chosen {
            
        }
        
        
    }
    
    
    
    
}
