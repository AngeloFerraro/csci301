#lang racket
;; Simple graphical Turing machine simulator
;;
;; Geoffrey Matthews 2005
;; See Hein, Chapter 13
;; modified 2010

;; The number of different bb Turing machines with N states:

(define numt
  (lambda (n)
    (expt (+ (* 4 n) 4) (* 2 n))))

(require (lib "graphics.ss" "graphics"))

(define tape-size 100000)
(define state 0)
(define mid-tape (quotient tape-size 2))
(define head mid-tape)
(define tape (make-vector tape-size '_))
(define (reset string)
  (set! state 0)
  (set! head (quotient tape-size 2))
  (do ((i 0 (+ i 1)))
    ((= i (vector-length tape)))
    (vector-set! tape i '_))
  (do ((s string (cdr s))
       (i head (+ 1 i)))
    ((null? s))
    (vector-set! tape i (car s))))

(define (x i)
  (case i
    ((r R) (set! head (+ head 1)))
    ((l L) (set! head (- head 1)))
    ((s S) '())))
(define (w s) (vector-set! tape head s))
(define (g) (vector-ref tape head))
(define (m s) (set! state s))

(define (rule machine)
  (cond ((null? machine) #f)
        ((and (eqv? (caar machine) state)
              (eqv? (cadar machine) (g))) (car machine))
        (else (rule (cdr machine)))))

(define (run machine)
  (show)
  (let ((r (rule machine)))
    (cond ((eqv? state 'halt) (show) 'accept)
          ((not r) (set! state 'reject) (show) 'reject)
          (else
           (w (caddr r))
           (x (cadddr r))
           (m (car (cddddr r)))
           (run machine)
           ))))

(define (test machine string)
  (reset string)
  (run machine)
  )

;; Graphical simulator
(open-graphics)
(define width 1200)
(define height 160)
(define vp (open-viewport "Turing Machine" width height))
(define pixels 24)
(define (tapewidth) (/ width pixels))
(define sleepamount 0.2)
  
(define (show)
  ((clear-viewport vp))
  (do ((x 0 (+ x pixels))
       (y pixels y)
       (i (- head (floor (/ (tapewidth) 2))) (+ i 1)))
    ((> x width))
    ((draw-rectangle vp) (make-posn x y) pixels pixels "black")
    ((draw-string vp) (make-posn (+ x 5) (+ y pixels -5)) 
                      (format "~a" (vector-ref tape i)))
    (when (= i head)
      ((draw-solid-rectangle vp) (make-posn x (* 2.25 pixels))
                                 pixels pixels "red" )
      ((draw-string vp) (make-posn x (* 3 pixels))
                        (format "~a" state)))
    (when (zero? (modulo i 10))
      ((draw-string vp) (make-posn x (* pixels 0.8)) (format "~a" (- i mid-tape))))
    )
  (sleep sleepamount))

;; Some machines 

;; Language recognizers:
(define anbm '((0 _ _ S halt)
               (0 a X R 0)
               (0 b X R 1)
               (1 b X R 1)
               (1 _ _ S halt)))

;(test anbm '(a a a b b))
;(test anbm '(a a b a))

(define anbncn '((0 a X R 1)
                 (0 Y Y R 0)
                 (0 Z Z R 4)
                 (0 _ _ S halt)
                 (1 a a R 1)
                 (1 b Y R 2)
                 (1 Y Y R 1)
                 (2 c Z L 3)
                 (2 b b R 2)
                 (2 Z Z R 2)
                 (3 a a L 3)
                 (3 b b L 3)
                 (3 X X R 0)
                 (3 Y Y L 3)
                 (3 Z Z L 3)
                 (4 Z Z R 4)
                 (4 _ _ S halt)))

;(test anbncn '(a a a a b b b b c c c c))
;(test anbncn '(a a b b c c c))
;(test anbncn '(a a b b c))

(define pal '((0 a X R 1)
              (0 b X R 2)
              (0 X X S halt)
              (1 a a R 1)
              (1 b b R 1)
              (1 _ _ L 3)
              (1 X X L 3)
              (2 a a R 2)
              (2 b b R 2)
              (2 _ _ L 4)
              (2 X X L 4)
              (3 a X L 5)
              (4 b X L 5)
              (5 a a L 5)
              (5 b b L 5)
              (5 X X R 0)))

;(test pal '(a b b a a b b a))

(define sameasbs '((0 a X L 1)
                   (0 b b R 0)
                   (0 X X R 0)
                   (0 _ _ L 4)
                   (1 X X L 1)
                   (1 b b L 1)
                   (1 _ _ R 2)
                   (2 a a R 2)
                   (2 b X L 3)
                   (2 X X R 2)
                   (3 a a L 3)
                   (3 b b L 3)
                   (3 X X L 3)
                   (3 _ _ R 0)
                   (4 X X L 4)
                   (4 _ _ R halt)))

;(test sameasbs '(b b a b a a a b))

;; Mathematical functions:
(define add2 '((0 1 1 L 0)
               (0 _ 1 L 1)
               (1 _ 1 S halt)))
;(test add2 '(1 1 1 1))

(define 2n '((0 1 _ R 1)
             (1 1 1 R 1)
             (1 _ _ R 2)
             (2 1 1 R 2)
             (2 _ 1 R 3)
             (3 _ 1 R 4)
             (4 _ _ L 5)
             (5 1 1 L 5)
             (5 _ _ L 6)
             (6 1 1 L 7)
             (6 _ _ R 8)
             (8 _ _ R halt)
             (7 1 1 L 7)
             (7 _ _ R 0)))
;(test 2n '(1 1 1))

(define add1binary '((0 0 0 R 0)
                     (0 1 1 R 0)
                     (0 _ _ L 1)
                     (1 0 1 L 2)
                     (1 1 0 L 1)
                     (1 _ 1 S halt)
                     (2 0 0 L 2)
                     (2 1 1 L 2)
                     (2 _ _ R halt)))
;(test add1binary '(1 1 0 1 1))
(define (rerun m n)
  (when (not (zero? n))
    (set! state 0) (run m) (rerun m (- n 1))))
;(rerun add1binary 5)

(define sub1binary '((0 0 0 R 0)
                     (0 1 1 R 0)
                     (0 _ _ L 1)
                     (1 0 0 L 1)
                     (1 1 0 R 2)
                     (2 0 1 R 2)
                     (2 _ _ L 3)
                     (3 0 0 L 3)
                     (3 1 1 L 3)
                     (3 _ _ R 4)
                     (4 0 _ R 4)
                     (4 1 1 S halt)))
;(rerun sub1binary 6)

(define equality '((0 1 _ R 1)
                   (0 _ _ R 4) 
                   (0 * * R 4)
                   
                   (1 1 1 R 1)
                   (1 _ _ L 2)
                   (1 * * R 1)
                   
                   (2 1 _ L 3)
                   (2 * 1 S halt)
                   
                   (3 1 1 L 3)
                   (3 _ _ R 0)
                   (3 * * L 3)
                   
                   (4 1 1 S halt)
                   (4 _ _ S halt)
                   (4 * * R 4)))

;(test equality '(1 1 1 * 1 1 1))
;(test equality '(1 1 * 1 1 1))
;(test equality '(1 1 1 * 1 1))

;; Input transducers:

(define revword '((0 a a R 0)
                  (0 b b R 0)
                  (0 _ _ L 1)
                  (1 X X L 1)
                  (1 a X R 2)
                  (1 b X R 3)
                  (1 _ _ R 5)
                  (2 X X R 2)
                  (2 a a R 2)
                  (2 b b R 2)
                  (3 X X R 3)
                  (3 a a R 3)
                  (3 b b R 3)
                  (2 _ a L 4)
                  (3 _ b L 4)
                  (4 a a L 4)
                  (4 b b L 4)
                  (4 X X L 1)
                  (5 X _ R 5)
                  (5 a a S halt)
                  (5 b b S halt)))

;(test revword '(a a a b b a))


;; Busy beavers:
(define bb2 '((0 _ 1 R 1)
              (0 1 1 L 1)
              (1 _ 1 L 0)
              (1 1 1 L halt)))

;(test bb2 '())

(define bb3 '((0 _ 1 R 1)
              (0 1 1 L 2)
              (1 _ 1 L 0)
              (1 1 1 R 1)
              (2 _ 1 L 1)
              (2 1 1 R halt)))
;(test bb3 '())

(define bb4 '((0 _ 1 R 1)
              (0 1 1 L 1)
              (1 _ 1 L 0)
              (1 1 _ L 2)
              (2 _ 1 R halt)
              (2 1 1 L 3)
              (3 _ 1 R 3)
              (3 1 _ R 0)))

;(test bb4 '())

;; Winner of the Scientific American competition was
;; a 5 state machine that outputs 1,915 1's before halting.
;; The current record holder for 5 state machine 
;; is the following with an output of 4098 1's

(define bb5 '((0 _ 1 L 1)
              (0 1 1 R 2)
              (1 _ 1 L 2)
              (1 1 1 L 1)
              (2 _ 1 L 3)
              (2 1 _ R 4)
              (3 _ 1 R 0)
              (3 1 1 R 3)
              (4 _ 1 L halt)
              (4 1 _ R 0)))

;; bb(6) >= 95,524,079

(define (bigbb)
  ((clear-viewport vp))
  (set! pixels 16)
  (set! sleepamount 0.2)
  (test bb5 '()))

;(bigbb)

