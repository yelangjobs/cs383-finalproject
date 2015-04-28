module Main where

------------------------------------------------------------------------

import Boids
import Model
import Linear.V2
import Graphics.Gloss hiding (Point)
import Graphics.Gloss.Interface.Pure.Simulate hiding (Point)
import Control.Monad.Random
import System.Environment( getArgs )
import System.Console.GetOpt
import System.Exit

------------------------------------------------------------------------

data Options = Options
  { optDebug       :: Bool
  , optMode        :: Action
  }

defaultOptions  = Options
  { optDebug    = False
  , optMode     = eqWeightStep
  }

options :: [OptDescr (Options -> IO Options)]
options =
  [ Option ['d']     ["debug"]
      (NoArg (\ opts -> return opts { optDebug = True}))
      "show debug mode"
  , Option ['c'] ["cohesive"]
      (NoArg (\ opts -> return opts { optMode = cohesiveStep }))
      "cohesive behaviour"
  , Option ['s'] ["swarm"]
      (NoArg (\ opts -> return opts { optMode = swarmStep }))
      "swarming behaviour"
  , Option ['e'] ["equal"]
      (NoArg (\ opts -> return opts { optMode = eqWeightStep}))
      "equal weighted behavioir"
  , Option "h" ["help"]
        (NoArg
            (\_ -> do
                putStrLn (usageInfo "Boids" options)
                exitWith ExitSuccess))
        "Show help"
  ]

drawBoid :: Boid -> Picture
drawBoid (Boid (V2 xpos ypos) (V2 xvel yvel) rad) =
  Translate xpos ypos $
  Pictures [ Circle 2
           , Color red $ Circle rad
           , Color green $ Line [(0,0), (xvel, yvel)]
           ]

drawWorld :: (Int, Int) -> World -> Picture
drawWorld (xdim, ydim) = Translate xtrans ytrans . Pictures . map drawBoid
  where xtrans = - fromIntegral xdim / 2
        ytrans = - fromIntegral ydim / 2

inBounds :: Float -> Float -> Float
inBounds bound = until (< bound) (subtract bound) . until (0 <=) (+ bound)

boundsCheck :: (Int, Int) -> World -> World
boundsCheck (width, height) = map modBoid
  where modBoid b@(Boid (V2 x y) _ _) = b { position = V2 (inWidth x) (inHeight y) }
        inWidth  = inBounds $ fromIntegral width
        inHeight = inBounds $ fromIntegral height

advanceWorld :: (Int, Int) -> Action -> ViewPort -> Float -> World -> World
advanceWorld dims step _ _ = boundsCheck dims . update step

main :: IO ()
main = do
  args <- getArgs

  -- Parse options, getting a list of option actions
  let (actions, nonOptions, errors) = getOpt RequireOrder options args

  -- Here we thread startOptions through all supplied option actions
  opts <- foldl (>>=) (return defaultOptions) actions

  let Options { optDebug = verbose
              , optMode  = mode } = opts

  let dims = (1000, 800)

  pos_x <- evalRandIO (initPos 20)
  pos_y <- evalRandIO (initPos 20)

  simulate (InWindow "Boids" dims (0, 0))
    (greyN 0.7)  -- background color
    30           -- updates per second
    (initWorld $ zip pos_x pos_y)
    (drawWorld dims)
    (advanceWorld dims (optMode opts))
