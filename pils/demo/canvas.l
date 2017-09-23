# 27aug17abu
# (c) Software Lab. Alexander Burger

(menu "Canvas"
   (form NIL
      (<h3> "fh" "Forest Fire")
      (unless *PRG
         (for Col (setq *FireGrid (grid *CanvasDX *CanvasDY))
            (for This Col
               (=: tree (rand T)) ) ) )
      (--)
      (<canvas> "$*FireGrid" *CanvasDX *CanvasDY)
      (javascript NIL "onload=drawCanvas('$*FireGrid', 40)") ) )

# vi:et:ts=3:sw=3
