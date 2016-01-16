module Main(main)
  where

import Pieces
import Data'
import Board
import UI'
import System.Random
import Data.Char
import Output'

start_delay :: Delay
start_delay = 1000

desired_dimensions :: (Vector, Vector)
desired_dimensions = (17,20)

get_new_piece :: IO Piece
get_new_piece = do x<-randomRIO(0,length pieces -1)
                   return (pieces !! x)

main :: IO ()
main = do 
          (width_ui,height_ui) <- init_ui
          let (width_des,height_des)=desired_dimensions
          let width = width_ui `min` width_des
              height = height_ui `min` height_des
          make_board width height
          piece <- get_new_piece
          let (b, cs) = create_board width height piece
          do_changes cs
          event_loop b start_delay

          (w,h)<-init_ui
          showThankyou
          
          shutdown_ui
          return ()

showThankyou :: IO ()
showThankyou =do (width_ui,height_ui) <- init_ui
                 let (width_des,height_des)=desired_dimensions
                 let width = width_ui `min` width_des
                     height = height_ui `min` height_des
                 make_board width height
                 thankyou width height
                 (m,_)<- get_event (start_delay*10000000)
                 if(m==Quit)
                    then do return ()
                    else main

event_loop :: Board -> Delay -> IO ()
event_loop b d = do 
                    (e,elapsed) <-get_event d
                    if e == Quit
                       then return ()
                       else do let (d' , e') = if elapsed <d && e /= Tick
                                                  then (d-elapsed, e)
                                                  else (start_delay, Tick)
                               if e' == Tick && not (can_down b)
                                  then do piece <-get_new_piece
                                          let (m_b' ,cs,_) = next_piece b piece
                                          do_changes cs
                                          case m_b' of
                                               Just b' -> event_loop b' d'
                                               Nothing -> return ()
                               else do let (b' ,cs) = get_changes b e'
                                       do_changes cs
                                       event_loop b' d'

