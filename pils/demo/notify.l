# 26aug17abu
# (c) Software Lab. Alexander Burger

(menu "Notify"
   (form NIL
      (<h3> "fh" "Notify")
      (form NIL
         (<grid> 2
            "Title" (gui '(+TextField) 30)
            "Message" (gui '(+TextField) 30) )
         (--)
         (gui '(+Able +JS +Button)
            '(and (val> (field -2)) (val> (field -1)))
            "Show Notification"
            '(notify (val> (field -2)) (val> (field -1)) 22) ) ) ) )

# vi:et:ts=3:sw=3
