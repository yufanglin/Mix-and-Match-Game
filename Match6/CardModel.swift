//
//  CardModel.swift
//  Match6
//
//  Created by Yufang Lin on 19/10/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

class CardModel: NSObject {
    
    func getCards() -> [Card] {
        // Create an empty array of Card object
        var cardArray = [Card]()
        
        // Create 8 pairs of cards by looping 8 times
        for _ in 1...8 {
            // Create a random number between 1-13
            let randomNum = Int(arc4random_uniform(13))
            
            // Create two card object instance
            let cardOne = Card()
            let cardTwo = Card()
            
            // Set the card's value to random number 
            cardOne.cardValue = randomNum
            cardTwo.cardValue = randomNum
            
            // Add cards into cardArray
            cardArray += [cardOne, cardTwo]
        }
        
        
        // Shuffle the deck by going through the cards and switching positions
        for cardIndex in 0...cardArray.count - 1 {
            // create a random index to switch a card index
            let randIndex = Int(arc4random_uniform(UInt32(cardArray.count)))
            
            // Keep track of the card at the random index 
            let randCard = cardArray[randIndex]
            
            // Switch cards 
            cardArray[randIndex] = cardArray[cardIndex]
            cardArray[cardIndex] = randCard
        }
        
        // Return the cards array
        return cardArray
    }
}
