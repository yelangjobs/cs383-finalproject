module Boids where

------------------------------------------------------------------------------

import Linear.V3

------------------------------------------------------------------------------

type Vector = V3 Float
type Point  = V3 Float
type Radius = Float

data Boid = Boid { position :: !Point
                 , target   :: !Point
                 , velocity :: !Vector
                 , radius   :: !Radius
                 }
  deriving (Show)

type Update = Boid -> Boid
type Perception = [Boid]
type Behaviour = Perception -> Update

emptyBehaviour :: Behaviour
            -- :: [Boid] -> Boid -> Boid
emptyBehaviour _ b = b

positions :: [Boid] -> [Vector]
positions = map position

separation :: [Boid] -> Vector
separation = undefined

cohesion :: [Boid] -> Vector
cohesion = undefined

alignment :: [Boid] -> Vector
alignment = undefined
