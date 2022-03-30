;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname fold-dir) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)

;; fold-dir-starter.rkt

;; In this exercise you will be need to remember the following DDs 
;; for an image organizer.

;; =================
;; Data definitions:

(define-struct dir (name sub-dirs images))
;; Dir is (make-dir String ListOfDir ListOfImage)
;; interp. An directory in the organizer, with a name, a list
;;         of sub-dirs and a list of images.

;; ListOfDir is one of:
;;  - empty
;;  - (cons Dir ListOfDir)
;; interp. A list of directories, this represents the sub-directories of
;;         a directory.

;; ListOfImage is one of:
;;  - empty
;;  - (cons Image ListOfImage)
;; interp. a list of images, this represents the sub-images of a directory.
;; NOTE: Image is a primitive type, but ListOfImage is not.

(define I1 (square 10 "solid" "red"))
(define I2 (square 12 "solid" "green"))
(define I3 (rectangle 13 14 "solid" "blue"))
(define D4 (make-dir "D4" empty (list I1 I2)))
(define D5 (make-dir "D5" empty (list I3)))
(define D6 (make-dir "D6" (list D4 D5) empty))

;; =================
;; Functions:

;; PROBLEM A:

;; Design an abstract fold function for Dir called fold-dir.

;; (String Y Z -> X) (X Y -> Y) (Image Z -> Z) Y Z Dir -> X
;; the abstract fold function for dir                  
(check-expect (local [(define (fn1 n rlod rloi) (+ rlod rloi))
                      (define (fn2 rdir rlod)   (+ 1 rdir))
                      (define (fn3 img rloi)    (+ 1 rloi))]
                (fold-dir fn1 fn2 fn3 0 0 D6))
              3)          


(define (fold-dir fn1 fn2 fn3 b2 b3 d)
  (local [(define (fn-for-dir d)                ; -> X
            (fn1 (dir-name d)                   ;String     
                 (fn-for-lod (dir-sub-dirs d))  ;ListOfDir
                 (fn-for-loi (dir-images d))))  ;ListOfImage

          (define (fn-for-lod lod)                   ;-> Y 
            (cond [(empty? lod) b2]
                  [else
                   (fn2 (fn-for-dir (first lod))
                        (fn-for-lod (rest lod)))]))
           
          (define (fn-for-loi loi)                    ;-> Z
            (cond [(empty? loi) b3]
                  [else
                   (fn3 (first loi)
                        (fn-for-loi (rest loi)))]))]
    (fn-for-dir d)))

;; PROBLEM B:

;; Design a function that consumes a Dir and produces the number of 
;; images in the directory and its sub-directories. 
;; Use the fold-dir abstract function.

;; Dir -> Number
;; interp. produce the number of images in a given directory and its subdirectories
(check-expect (local [(define (fn1 n rlod rloi) (+ rlod rloi))
                      (define (fn2 rdir rlod)   (+ 1 rdir))
                      (define (fn3 img rloi)    (+ 1 rloi))]
                (fold-dir fn1 fn2 fn3 0 0 D6))
              3)
(check-expect (count-images D6) 3)

(define (count-images d)
  (local [(define (fn1 n rlod rloi) (+ rlod rloi))
          (define (fn2 rdir rlod) (+ 1 rdir))
          (define (fn3 img rloi) (+ 1 rloi))]
    (fold-dir fn1 fn2 fn3 0 0 d)))

;; PROBLEM C:

;; Design a function that consumes a Dir and a String. The function looks in
;; dir and all its sub-directories for a directory with the given name. If it
;; finds such a directory it should produce true, if not it should produce false. 
;; Use the fold-dir abstract function.

;; String Dir -> Boolean
;; interp. produce true if a given directory is found
(check-expect (search-dir "D6" D4) false)
(check-expect (search-dir "D6" D6) true)
(check-expect (search-dir "D5" D6) true)

;(define (search-dir n d) false)

(define (search-dir n d)
  (local [(define (fn1 d-name rdirs rimgs)
            (or (string=? n d-name)
                rdirs
                rimgs))
          (define (fn2 rdir rdirs)
            (or rdir rdirs))
          (define (fn3 img rimgs)
            false)]
    (fold-dir fn1 fn2 fn3 false false d)))
                                   
    

;; PROBLEM D:

;; Is fold-dir really the best way to code the function from part C? Why or 
;; why not?

;; No. In line 90 the directory we are searching for is the very first item we find.
;; However, fold-dir does not have the ability to break-out from the search once
;; a match has been found.