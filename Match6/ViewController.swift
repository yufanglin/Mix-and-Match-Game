//
//  ViewController.swift
//  Match6
//
//  Created by Yufang Lin on 19/10/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // Card Variables
    var model = CardModel()
    var cards = [Card]()
    var revealedCard: Card?
    
    
    // Countdown Variables
    @IBOutlet weak var countdownLabel: UILabel!
    var countdown = 60
    var timer: Timer?
    
    
    // Score Variables 
    var correctCounter = 0
    var wrongCounter = 0
    var totalAttempts = 0
    var correctAttempts: Double = 0.00
    
    // Score Labels
    @IBOutlet weak var correctCounterLabel: UILabel!
    @IBOutlet weak var incorrectCounterLabel: UILabel!
    @IBOutlet weak var totalAttemptsLabel: UILabel!
    @IBOutlet weak var correctAttemptsLabel: UILabel!
    

    // Stack View Variables
    var stackViewArray = [UIStackView]()
    @IBOutlet weak var firstStackView: UIStackView!
    @IBOutlet weak var secondStackView: UIStackView!
    @IBOutlet weak var thirdStackView: UIStackView!
    @IBOutlet weak var fourthStackView: UIStackView!
    
    
    // Feedback Variables
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    
    
    // Constraing Variables
    @IBOutlet weak var topFeedbackConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomFeedbackConstraint: NSLayoutConstraint!
    
    
    
    // Sound Variables
    var cardflipSoundPlayer: AVAudioPlayer?
    var correctSoundPlayer: AVAudioPlayer?
    var wrongSoundPlayer: AVAudioPlayer?
    var shuffleSoundPlayer: AVAudioPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Dispose of any resources that can be recreated.
        
        // Hide feedback view
        dimView.alpha = 0
        
        // initialize sounds
        initSound()
        
        // fill stackview
        stackViewArray += [firstStackView, secondStackView, thirdStackView, fourthStackView]
        
        // create cards
        cards = model.getCards()
        
        // layout cards
        layoutCards()
        
        // Set timer
        countdownLabel.text = String(countdown)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerUpdate), userInfo: self, repeats: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // -------------------- GAME LOGIC FUNCTION --------------- \\
    func layoutCards() {
        // play shuffle sound
        shuffleSoundPlayer?.play()
        
        // keep track of the current index in card array
        var cardIndex = 0
        
        // Loop through the stackViews
        for stackView in stackViewArray {
            // loop through each card in a row
            for _ in 1...4 {
                // get card from array
                let card = cards[cardIndex]
                
                // set card's auto layout to false
                card.translatesAutoresizingMaskIntoConstraints = false
                
                // create a tap gesture recognizer
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapRecog(gestureReco:)))
                
                // add recognizer to the card
                card.addGestureRecognizer(recognizer)
                
                // Create height constraint of 170 for the card object
                let heightConstraint = NSLayoutConstraint(item: card, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 170)
                
                // Create width constraint of 120 for the card object
                let widthConstraint = NSLayoutConstraint(item: card, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 120)
                
                // add constraints to card
                card.addConstraints([heightConstraint, widthConstraint])
                
                // add card to stackView
                stackView.addArrangedSubview(card)
                
                // increment card's index
                cardIndex += 1
            }
        }
    }
    
    
    func timerUpdate() {
        // decrement counter
        countdown -= 1
        
        // Check if countdown is is 0
        if countdown == 0 {
            // Stop timer
            timer?.invalidate()
            
            // create a color object to keep track of the player game stat 
            var color = UIColor()
            
            // Create a flag to keep track of all pair's state
            var allFound = true
            
            // Loop through all cards to find an unmatched card
            for card in cards {
                // Find a card that hasn't been matched
                if card.isDone == false {
                    // card not found, set flag to false
                    allFound = false
                    // already found one, can stop looping
                    break
                }
            }
            
            // check the state of pairs
            if allFound {
                // all cards found
                color = UIColor.green
            }
            else {
                // not all cards found
                color = UIColor.red
            }
            
            // set feedback view
            setFeedback(color: color)
        }
        
        // check if countdown is less than 11
        if (countdown < 11) {
            // set label color 
            countdownLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.6)
            
            
        }
        
        // display current countdown
        countdownLabel.text = String(countdown)
    }
    
    func tapRecog (gestureReco: UITapGestureRecognizer) {
        
        // Check if the timer's up
        if countdown == 0 {
            // prevent users from tapping on card
            return
        }
        
        // Get the view from gesture recognizer and save as a Card Object
        let card = gestureReco.view as! Card
        
        // check if card is already flipped
        if card.flippedUp == false {
            // play card flip sound
            cardflipSoundPlayer?.play()
            
            // flip card
            card.flipUp()
            
            // Check if card is already revealed
            if revealedCard == nil {
                // First card in pair, keep track of this card
                revealedCard = card
            }
            else {
                // Second card in pair, check if they match
                if revealedCard?.cardValue == card.cardValue {
                    // Correct match, set card state to matched 
                    revealedCard?.isDone = true
                    card.isDone = true
                    
                    // play correct sound player
                    correctSoundPlayer?.play()
                    
                    // reset revealed card
                    revealedCard = nil
                    
                    // increment score
                    correctCounter += 1
                    totalAttempts += 1
                    
                    // check if this is the last pair of cards
                    checkPairs()
                }
                else {
                    // incorrect match
                    
                    // play wrong sound player
                    wrongSoundPlayer?.play()
                    
                    // delay cards to show animation
                    let _ = Timer.scheduledTimer(timeInterval: 1, target: card, selector: #selector(Card.flipDown), userInfo: nil, repeats: false)
                    
                    let _ = Timer.scheduledTimer(timeInterval: 1, target: revealedCard!, selector: #selector(Card.flipDown), userInfo: nil, repeats: false)
                    
                    // reset revealed card
                    revealedCard = nil
                    
                    // increment score
                    wrongCounter += 1
                    totalAttempts += 1
                }
            }
        }
    }
    
    func checkPairs() {
        
        // Create a flag to keep track of whether or not all cards been matched
        var allFound = true
        
        // Loop through all cards 
        for card in cards {
            // check the state of the card
            if card.isDone == false {
                // a card wasn't found, so not all pairs matched
                allFound = false
                // not found card, so not necessary to continue looping 
                break
            }
        }
        
        // In case all cards found
        if allFound {
            // stop timer
            timer?.invalidate()
            
            // set the feedback view to all found values
            setFeedback(color: UIColor.green)
        }
    }
    
    // -------------------- FEEDBACK FUNCTION --------------- \\
    @IBAction func playAgainTapped(_ sender: Any) {
        // hide the feedback view
        dimView.alpha = 0
        
        // Restart
        restart()
    }
    
    func restart() {
        // Loop through all cards
        for card in cards {
            // remove cards
            card.removeFromSuperview()
        }
        
        // play shuffle sound
        shuffleSoundPlayer?.play()
        
        // create cards
        cards = model.getCards()
        
        // layout cards
        layoutCards()
        
        // reset scores
        correctCounter = 0
        wrongCounter = 0
        totalAttempts = 0
        correctAttempts = 0.00
        
        // reset labels
        correctAttemptsLabel.text = String(correctCounter)
        incorrectCounterLabel.text = String(wrongCounter)
        totalAttemptsLabel.text = String(totalAttempts)
        correctAttemptsLabel.text = String(correctCounter)
        
        // Reset timer
        countdown = 60
        countdownLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)
        countdownLabel.text = String(countdown)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
    }
    
    func setFeedback(color: UIColor) {
        if color == UIColor.green {         // All cards matched
            // set background color
            feedbackView.backgroundColor = UIColor(red: 85/255, green: 126/255, blue: 85/255, alpha: 0.5)
            
            // set button background color
            playAgainButton.backgroundColor = UIColor(red: 21/255, green: 32/255, blue: 21/255, alpha: 0.5)
            
            // Set result label
            resultLabel.text = "Pairs All Found!"
        }
        else {                              // Time's up
            // Set background color
            feedbackView.backgroundColor = UIColor(red: 75/255, green: 0/255, blue: 0/255, alpha: 0.5)
            
            // set button background color
            playAgainButton.backgroundColor = UIColor(red: 21/255, green: 0/255, blue: 0/255, alpha: 0.5)
            
            // set result label
            resultLabel.text = "Time's Up!"
        }
        
        // Check if attempts were even made
        if (totalAttempts > 0) {
            // calculate the total correct attempts
            correctAttempts = (Double(correctCounter) / Double(totalAttempts)) * 100
        }
        else {
            // set number to 0
            correctAttempts = 0.00
        }
        
        // Set score label
        correctCounterLabel.text = String(correctCounter)
        incorrectCounterLabel.text = String(wrongCounter)
        totalAttemptsLabel.text = String(totalAttempts)
        correctAttemptsLabel.text = "\(String(format: "%.2f", correctAttempts))%"
        
        // Prepare Animation: move feedback off screen by resetting constraints
        topFeedbackConstraint.constant = 1000
        bottomFeedbackConstraint.constant = -1000
        
        // update constraint changes immediately 
        view.layoutIfNeeded()
        
        // Animate
        UIImageView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: { 
            // Show feedback view
            self.dimView.alpha = 1
            
            // Move feedback onto screen by resetting constraints
            self.topFeedbackConstraint.constant = 30
            self.bottomFeedbackConstraint.constant = 30
            
            // update constraint changes immediately
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    func initSound() {
        // Initialize card flip player
        do {
            // Create path to cardflip.wav file
            let path = Bundle.main.path(forResource: "cardflip", ofType: "wav")
            
            // Create url object on path 
            let url = URL(fileURLWithPath: path!)
            
            // Set card flip player
            cardflipSoundPlayer = try AVAudioPlayer(contentsOf: url)
        }
        catch{
            fatalError("Error in initializing card flip sound player")
        }
        
        // Initialize correct sound player
        do {
            // Create path to dingcorrect.wav file
            let path = Bundle.main.path(forResource: "dingcorrect", ofType: "wav")
            
            // Create url object on path
            let url = URL(fileURLWithPath: path!)
            
            // Set ding correct player
            correctSoundPlayer = try AVAudioPlayer(contentsOf: url)
        }
        catch {
            fatalError("Error in initializing correct sound player")
        }
        
        
        // Initialize wrong sound player
        do {
            // Create path object to dingwrong.wav file
            let path = Bundle.main.path(forResource: "dingwrong", ofType: "wav")
            
            // Create url object on path object
            let url = URL(fileURLWithPath: path!)
            
            // Set ding wrong player
            wrongSoundPlayer = try AVAudioPlayer(contentsOf: url)
        }
        catch {
            fatalError("Error in initializing wrong sound player")
        }
        
        // Initialize shuffle sound player
        do {
            // Create path object to shuffle.wav file
            let path = Bundle.main.path(forResource: "shuffle", ofType: "wav")
            
            // Create url object on path
            let url = URL(fileURLWithPath: path!)
            
            // Set the shuffle player
            shuffleSoundPlayer = try AVAudioPlayer(contentsOf: url)
        }
        catch {
            fatalError("Error in initializing shuffle sound player")
        }
    }
}

