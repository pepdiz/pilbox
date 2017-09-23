# 26aug17abu
# (c) Software Lab. Alexander Burger

(menu "Camera"
   (form NIL
      (<h3> "fh" "Camera")
      (form NIL
         (gui '(+Able +Button) '(camera?) "Take Picture"
            '(takePicture (tmp "img")
               '((Intent)
                  (setq *Picture (tmp "img"))
                  (loadUrl (baseHRef) *SesId "demo/camera.l") ) ) )
         (----)
         (gui '(+Var +Img) '*Picture NIL NIL 400 400) ) ) )

# vi:et:ts=3:sw=3
