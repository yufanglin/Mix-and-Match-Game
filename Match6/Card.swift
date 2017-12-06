//
//  Card.swift
//  Match6
//
//  Created by Yufang Lin on 19/10/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

class Card: UIView {
    
    // Card Image View Variables
    var frontImageView = UIImageView()
    var backImageView = UIImageView()

    // Card variables
    var cards = ["card1", "card2", "card3", "card4", "card5", "card6", "card7", "card8", "card9",
               "card10", "card11", "card12", "card13"]
    var cardValue = 0
    
    // Card state variables
    var flippedUp = false
    var isDone = false {
        // Card matched
        didSet {
            if isDone == true {
                // Animate cards off screen
                UIImageView.animate(withDuration: 1, delay: 1, options: .curveEaseOut, animations: {
                    // Hide matched card
                    self.backImageView.alpha = 0
                    self.frontImageView.alpha = 0
                    
                }, completion: nil)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // ---------- Set Back Image View --------- \\
        // add card into the superview (Card class)
        addSubview(backImageView)
        
        // set image auto layout default to false 
        backImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set image
        backImageView.image = UIImage(named: "back")
        
        // set height constraint
        setSizeConstraints(imageView: backImageView)
        
        // set position constraint
        setPositionConstraints(imageView: backImageView)
        
        
        // ---------- Set Front Image View --------- \\ 
        // add card to view (Card)
        addSubview(frontImageView)
        
        // set autolayout default to false
        frontImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // set height constraint
        setSizeConstraints(imageView: frontImageView)
        
        // set width constraint
        setPositionConstraints(imageView: frontImageView)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    func setSizeConstraints(imageView: UIImageView) {
        // Create height constraint for imageView
        let heightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 170)
        
        // Create width constraint for imageView
        let widthConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 120)
        
        // Add Constraints to imageView
        imageView.addConstraints([heightConstraint, widthConstraint])
    }
    
    func setPositionConstraints(imageView: UIImageView) {
        // Create top constraint for imageView
        let topConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        
        // Create left constraint for imageView
        let leftConstraint = NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        
        // Add Constraints to ViewController
        addConstraints([topConstraint, leftConstraint])
    }
    
    func flipUp() {
        // Set the image of the front side of card
        frontImageView.image = UIImage(named: cards[cardValue])
        
        // Animate from back side to front side
        UIImageView.transition(from: backImageView, to: frontImageView, duration: 1, options: .transitionFlipFromLeft, completion: nil)
        
        // Set position to make sure when flipped, the cards don't change position
        setPositionConstraints(imageView: frontImageView)
        
        // Set card state to flipped up
        flippedUp = true
    }
    
    func flipDown() {
        // Animate from front to back 
        UIImageView.transition(from: frontImageView, to: backImageView, duration: 1, options: .transitionFlipFromRight, completion: nil)
        
        // Set position 
        setPositionConstraints(imageView: backImageView)
        
        // Set card state to flip down
        flippedUp = false
    }
}
