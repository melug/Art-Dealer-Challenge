# Art Dealer Challenge
[Simulation of Art Dealer Challenge](http://alten.softwareskills.se/#/contest/59c13cdb636f91cb1900c492)

Objective of this simulation is not about solving the challenge, rather I focused on haskell code. 

I tried to achieve series of objectives and see where it goes, which includes:
  
## 1. Create data structure whenever it is possible. 
   
   Problem statement says we have 4 different categories for paintings namingly Red, Blue, Green, Yellow.
   In this part we could have used numbers for categories like 0 for Red, 1 for Red etc.
   But the problem is, this kind of storage can lead to difficult to understand "code". 
   For example:
   ```haskell
   -- | Ask bid for given painting from the player
   getBid :: Painting -> Player -> Int
   ```
   is much better than:
   ```haskell
   -- | Ask bid for given painting from the player
   getBid :: Int -> Int -> Int
   ```
   on top of that, errors can be caught at compile time rather than run time. Integers can be slippery and might pass the type checker!
   And this problem could be saved by only one line of code:
   ```haskell
   data Painting = Red | Blue | Green | Yellow deriving (Enum, Eq, Show, Ord, Bounded)
   ```
   I even created Bidder data structure for auction. Check that out! it made code very clean.
   
## 2. Abstract the problem as much as possible

   Let's talk about implementation of bidding in the simulation.
   
   Thought process for imperative language could be like this:
   
   * Save first player as highest bidder in some variable
   * Then loop through rest of the players, if any of them bids higher than highest bidder, save it in highest bidder variable
   * At the end of loop, deduce money from highest bidder and add the picture to his collection
   * Remove the current painting from auction
   
   Thought process for functional language:
   
   * Make new auction with new state of players
   * New state of players is that highest bidder has added the painting to his collection and money is deduced from his pocket
   * New state of auction doesn't have current picture, and has highest bidder in set of players
   
In the conclusion, I think I achieved more readable and correct code.

Look at this code:
```
simulateGame :: Auction -> Auction
simulateGame = until isAuctionEnded playRound
```
Which simulates auction until gallery runs out of paintings. It's amazingly readable and correct.
