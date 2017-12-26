import System.Random
import Data.List

-- | Category of paintings
data Painting = Red | Blue | Green | Yellow deriving (Enum, Eq, Show, Ord, Bounded)

-- | Player, which consists of amount of money and paintings which has been bought
data Player = Player { money :: Int, paintings :: [Painting] } deriving (Show)

-- | Bidder, amount of money which the player has bid at auction
type Bidder = (Int, Player)

-- | Auction, which consists of participants i.e players and categories
data Auction = Auction { players :: [Player], categories :: [Painting] }
    deriving (Show)

-- | Initial player, all players are initialized to money 100, and empty paintings
initialPlayer :: Player
initialPlayer = Player { money = 100, paintings = [] }

-- | Initial auction, 4 initial players and list of paintings which are randomly
-- generated.
initialAuction :: IO Auction
initialAuction = do
    categories <- draws []
    return $ Auction { players = replicate 4 initialPlayer, categories = categories }

allPaintingLength :: Int
allPaintingLength = fromEnum (maxBound :: Painting)

-- | Generate all type of painting, one for each category
allPaintings :: [Painting]
allPaintings = [ (toEnum 0) .. (toEnum (allPaintingLength - 1)) ]

-- | Generate random painting, 
randomPainting :: IO Painting
randomPainting = fmap toEnum randIndex
    where randIndex = getStdRandom (randomR (0, allPaintingLength - 1))

-- | Generate list of paintings until number of pictures in
-- one of categories reaches 5.
draws :: [Painting] -> IO [Painting]
draws ps
  | over4     = return ps
  | otherwise = do
      p <- randomPainting
      draws (p:ps)
    where counts = map length $ group (sort ps)
          over4  = any (>4) counts

-- | Count categories in list paintings. 
countPainting :: [Painting] -> [(Painting, Int)]
countPainting ps = map (\p -> (head p, length p)) $ group (sort ps)

-- | Add paintings which are not occured in the list of paintings.
-- Also if number of paintings is greater than 4, fix it back to 4
fixPaintingList :: [(Painting, Int)] -> [(Painting, Int)]
fixPaintingList paintPairs = replacePainting paintPairs ++ absentPaintings
    where absentPaintings = zip (allPaintings \\ (fst $ unzip paintPairs)) (repeat 0)

-- | If frequency is over 4, set back to 4
topPaintings :: [(Painting, Int)] -> [(Painting, Int)]
topPaintings []         = []
topPaintings ((p,f):ps)
  | f>4                    = (p,4):(topPaintings ps)
  | otherwise              = (p,f):(topPaintings ps)
        
-- | Set scores to the paintings.
score :: [Painting] -> [(Painting, Int)]
score ps = zip (map fst $ sortBy comparePainting $ fixPaintingList $ countPainting ps) (reverse [0, 10 .. 30])

comparePainting :: (Painting, Int) -> (Painting, Int) -> Ordering
comparePainting (p0, i0) (p1, i1)
  | i0 == i1  = compare p0 p1
  | otherwise = flip compare i0 i1

-- | If categories in auction is empty, we have ran out of
-- paintings.
isAuctionEnded :: Auction -> Bool
isAuctionEnded (Auction { players = _, categories = [] }) = True
isAuctionEnded otherwise                                  = False

-- | Ask bid for given painting from the player
getBid :: Painting -> Player -> Int
getBid p (Player { money = m, paintings = ps })
  | m > 30    = 30
  | otherwise = (div m 2)

-- | Simulate single round
playRound :: Auction -> Auction
playRound (Auction { players = ps, categories = (c:cs) }) = Auction { players = updatePlayers, categories = cs }
    where highestBidder = maximumBy compareBidder (zip [0..] $ map (\p -> (getBid c p, p)) ps)
          compareBidder (_, (b0, _)) (_, (b1, _)) = compare b0 b1
          updatePlayers = map (updatePlayer highestBidder) (zip [0..] ps)
          updatePlayer (i0, (b0, Player { money = m0, paintings = p0s })) (i1, pl1) 
            | i0 == i1  = Player { money = m0-b0, paintings = c:p0s }
            | otherwise = pl1

-- *> a <- initialGame
-- *> simulateGame a
simulateGame :: Auction -> Auction
simulateGame = until isAuctionEnded playRound
