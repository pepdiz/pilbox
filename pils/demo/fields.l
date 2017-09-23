# 15sep17abu
# (c) Software Lab. Alexander Burger

(menu "Text Fields"
   (form NIL
      (<h3> "fh" "Text Fields")
      (<tab>
         ("Fields"
            (<grid> 2
               "Text" (gui '(+Var +TextField) '*DemoText 20)
               "E-Mail" (gui '(+Var +MailField) '*DemoMail 20)
               "Checkbox" (gui '(+Var +Checkbox) '*DemoCheck)
               "Radio A" (gui '(+Var +Radio) '*DemoRadio NIL "A")
               "Radio B" (gui '(+Radio)  -1 "B")
               "Radio C" (gui '(+Radio)  -2 "C") )
            (<grid> 3
               "Date" (gui '(+Var +DateField) '*DemoDate 10)
               (gui '(+JS +Button) "Today" '(set> (field -1) (date)))
               "Time" (gui '(+Var +TimeField) '*DemoTime 10)
               (gui '(+JS +Button) "Now" '(set> (field -1) (time)))
               "Number" (gui '(+Var +NumField) '*DemoNum 10)
               (gui '(+JS +Button) "Increment" '(inc '*DemoNum))
               "Fixnum" (gui '(+Var +FixField) '*DemoFix 2 10)
               (gui '(+JS +Button) "Increment" '(inc '*DemoFix 100)) ) )
         ("Area"
            (gui '(+Var +TextField) '*DemoArea 64 32) )
         ("Life"
            (unless *PRG
               (for Col (=: grid (grid 32 32))
                  (for This Col
                     (=: life (rand T)) ) ) )
            (gui '(+Style +View +TextField) "mono"
               '(pack
                  (make
                     (for Col (: home grid)
                        (for This Col
                           (link (if (: life) "X " "  ")) )
                        (link "^J") ) ) )
               64 32 )
            (----)
            (gui '(+Click +Auto +Button) 420 'This 1000 '(pop *Throbber)
               '(with (: home)
                  (for Col (: grid)
                     (for This Col
                        (let N  # Count neighbors
                           (cnt
                              '((Dir) (get (Dir This) 'life))
                              (quote
                                 west east south north
                                 ((X) (south (west X)))
                                 ((X) (north (west X)))
                                 ((X) (south (east X)))
                                 ((X) (north (east X))) ) )
                           (=: next  # Next generation
                              (if (: life)
                                 (>= 3 N 2)
                                 (= N 3) ) ) ) ) )
                  (for Col (: grid)  # Update
                     (for This Col
                        (=: life (: next)) ) ) ) ) ) ) ) )

# vi:et:ts=3:sw=3
