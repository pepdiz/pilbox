# 17sep17abu
# (c) Software Lab. Alexander Burger

,"Demo"

(once
   (allow "!demo")
   (load "@lib/simul.l")
   (setq
      *CanvasDX 480
      *CanvasDY 360 )
   (seed (in "/dev/urandom" (rd 8))) )

(de demo ()
   (pilbox "!demo" "demo/")
   (menu "Pil Demo"
      (<layout> T
         ((50 15)
            (<div> @
               (<button> "demo/fields.l?*Tab=+1" "Fields") )
            ((50 15)
               (<div> @
                  (<button> "demo/charts.l?*Tab=+1" "Charts") ) ) )
         ((50 15)
            (<div> @
               (<button> "demo/canvas.l?*Tab=+1" "Canvas") )
            ((50 15)
               (<div> @
                  (<button> "demo/fields.l?*Tab=+3" "Life") ) ) )
         ((50 15)
            (<div> @
               (<button> "demo/camera.l" "Camera") )
            ((50 15)
               (<div> @
                  (<button> "demo/scan.l" "Scan") ) ) )
         ((50 15)
            (<div> @
               (<button> "demo/maps.l?*Tab=+1" "GPS") )
            ((50 15)
               (<div> @
                  (<button> "demo/notify.l" "Notify") ) ) ) ) ) )

### Utility Functions ###
(de mkChartData (I)
   (list
      (bit? 1 I)
      I
      (pack
         (cons
            (char (+ 64 I))
            (need 5 (char (+ 96 I))) ) ) ) )

(de mkDemoTable (Rows)
   (<table> NIL "Chart" '((btn) (align "Number") (NIL "Text"))
      (do 7
         (<row> NIL
            (gui 1 '(+Checkbox))
            (gui 2 '(+Sgn +NumField) 12)
            (gui 3 '(+TextField) 12)
            (gui 4 '(+DelRowButton))
            (gui 5 '(+BubbleButton)) ) ) ) )

(de drawCanvas (Id Dly)
   (for Col *FireGrid
      (for This Col
         (=: next
            (cond
               ((: burn) NIL)
               ((: tree)
                  (if
                     (or
                        (find  # Neighbor burning?
                           '((Dir) (get (Dir This) 'burn))
                           (quote
                              west east south north
                              ((X) (south (west X)))
                              ((X) (north (west X)))
                              ((X) (south (east X)))
                              ((X) (north (east X))) ) )
                        (=0 (rand 0 9999)) )
                     'burn
                     'tree ) )
               (T (and (=0 (rand 0 99)) 'tree)) ) ) ) )
   (for Col *FireGrid
      (for This Col
         (if (: next)
            (put This @ T)
            (=: burn)
            (=: tree) ) ) )
   (make
      (csClearRect 0 0 *CanvasDX *CanvasDY)
      (csFillStyle "green")
      (csDrawDots 1 1
         (make
            (for (X . Col) *FireGrid
               (for (Y . This) Col
                  (and (: tree) (link X Y)) ) ) ) )
      (csFillStyle "red")
      (csDrawDots 3 3
         (make
            (for (X . Col) *FireGrid
               (for (Y . This) Col
                  (and (: burn) (link X Y)) ) ) ) ) ) )

(setq *Url "!demo")
(demo)

# vi:et:ts=3:sw=3
