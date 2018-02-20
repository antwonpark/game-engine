#lang racket

;Optimize! 20x20 is too slow
;Clear up code more
;Better abstractions.  Different types of ground.  Procedurally generate combiner tiles?
;Collidable tiles
;Controllable character
;Multiplayer

(require 2htdp/image)
(require 2htdp/universe)


(require "grids.rkt")
(require "sheets.rkt")
(require "marching-squares.rkt")

(define WIDTH  10)
(define HEIGHT 10)
(define GROUND_TILE_SIZE 32)

(define example (make-sheet (bitmap "./ground-tiles.png") GROUND_TILE_SIZE))

(define grass-tile ((sheet-get example) 6 3))
(define grass-sym  'g)

(define (ground-data)
  (grid-of 's WIDTH HEIGHT))

(define (ground)
  (add-noise 's 0.0
             (grid-of 'g WIDTH HEIGHT)))

(define (sheet->combiner-tiles off-x off-y)
  (flatten (list
            (list (sub-div ((sheet-get example) off-x off-y))       (sub-div ((sheet-get example) (+ 1 off-x) off-y)))
            (list (sub-div ((sheet-get example) off-x (+ 1 off-y))) (sub-div ((sheet-get example) (+ 1 off-x) (+ 1 off-y))))
            (list (sub-div ((sheet-get example) off-x (+ 2 off-y))) (sub-div ((sheet-get example) (+ 1 off-x) (+ 2 off-y)))))))

(define grass-stone-sheet (sheet->combiner-tiles 0 0))

(define big-ground (ground))

(define (paint s x y event)
  (define g (second s))
  (if (string=? event "button-down")
      (list (first s)
            (grid-set g
                (floor (/ y GROUND_TILE_SIZE))
                (floor (/ x GROUND_TILE_SIZE)) 's))
      s))

(define (current-frame time)
  (* 2 (remainder time 3)))

(define (draw s)
  (define g (second s))
  (merge-tiles (render2 g (list-getter (sheet->combiner-tiles (current-frame (first s)) 0)) grass-tile )))

(define (tick s)
  (list (add1 (first s))
        (second s)))


(merge-tiles (render2 big-ground (list-getter grass-stone-sheet) grass-tile ))

(merge-tiles
 (render2
  (second (big-bang (list 0 big-ground)
                    (on-tick tick)
                    (to-draw draw)
                    (on-mouse paint)))
  (list-getter grass-stone-sheet) grass-tile))










