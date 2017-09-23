# 26aug17abu
# (c) Software Lab. Alexander Burger

(menu "Charts"
   (form NIL
      (<h3> "fh" "Charts")
      (<tab>
         ("Fixed"
            (gui '(+Init +Chart) (mapcar mkChartData (range 1 12)) 5)
            (mkDemoTable)
            (scroll 7 T) )
         ("Unlimited"
            (gui '(+QueryChart) 7
               '(goal '((for @N T) (^ @@ (mkChartData (-> @N)))))
               5 )
            (mkDemoTable)
            (scroll 7) ) ) ) )

# vi:et:ts=3:sw=3
