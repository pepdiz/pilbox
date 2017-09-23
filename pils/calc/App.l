# 17sep17abu
# (c) Software Lab. Alexander Burger

,"Calculator"

# *Init *Accu *Stack

(allow "!calculator")

# Calculator logic
(de start ()
   (on *Init)
   (zero *Accu)
   (off *Stack) )

(de digit (N)
   (when *Init
      (zero *Accu)
      (off *Init) )
   (setq *Accu
      ((if (lt0 *Accu) - +) (* 10 *Accu) N) ) )

(de calculate ()
   (let (Fun (caar *Stack)  Val (cddr (++ *Stack)))
      (setq *Accu
         (if (and (== '/ Fun) (=0 *Accu))
            (note "Div / 0")
            (Fun Val *Accu) ) ) ) )

(de operand (Fun Prio)
   (when (>= (cadar *Stack) Prio) (calculate))
   (push '*Stack (cons Fun Prio *Accu))
   (on *Init) )

(de finish ()
   (while *Stack (calculate))
   (on *Init) )

# Calculator GUI
(de calculator ()
   (pilbox "!calculator" "calc/")
   (setq *Locales
      (quote
         ("English" NIL)
         ("Deutsch (DE)" "DE" . "de")
         ("Deutsch (CH)" "CH" . "ch") ) )
   (menu ,"Bignum Calculator"
      (form "calc"
         (<layout> T
            ((10 NIL)
               (<div> @)
               ((80 60)
                  (<div> @
                     (<h2> "center" ,"Bignum Calculator")
                     (gui '(+Var +NumField) '*Accu 40)
                     (----)
                     (<grid> 4
                        (gui '(+JS +Button) "±" '(setq *Accu (- *Accu)))
                        (gui '(+Able +JS +Button) '(ge0 *Accu) "√"
                           '(setq *Accu (sqrt *Accu)) )
                        (gui '(+JS +Button) "\^" '(operand '** 3))
                        (gui '(+JS +Button) "/" '(operand '/ 2))
                        (gui '(+JS +Button) "7" '(digit 7))
                        (gui '(+JS +Button) "8" '(digit 8))
                        (gui '(+JS +Button) "9" '(digit 9))
                        (gui '(+JS +Button) "*" '(operand '* 2))
                        (gui '(+JS +Button) "4" '(digit 4))
                        (gui '(+JS +Button) "5" '(digit 5))
                        (gui '(+JS +Button) "6" '(digit 6))
                        (gui '(+JS +Button) "-" '(operand '- 1))
                        (gui '(+JS +Button) "1" '(digit 1))
                        (gui '(+JS +Button) "2" '(digit 2))
                        (gui '(+JS +Button) "3" '(digit 3))
                        (gui '(+JS +Button) "+" '(operand '+ 1))
                        (gui '(+JS +Button) "0" '(digit 0))
                        (gui '(+JS +Button) "C" '(zero *Accu))
                        (gui '(+JS +Button) "A" '(start))
                        (gui '(+JS +Button) "=" '(finish)) ) ) ) ) ) ) ) )

(start)
(setq *Url "!calculator")
(calculator)
