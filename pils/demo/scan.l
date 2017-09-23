# 15sep17abu
# (c) Software Lab. Alexander Burger

(menu "Scan"
   (form NIL
      (<h3> "fh" "Scan")
      (unless (zxing?)
         (<p> "tiny red"
            ,"Please install QR-Code scanner" ) )
      (form NIL
         (gui '(+Button) "Scan QR-Code"
            '(scanQR
               '((Intent)
                  (setq *QR-Code (java Intent 'getStringExtra "SCAN_RESULT"))
                  (loadUrl (baseHRef) *SesId "demo/scan.l") ) ) )
         (----)
         (gui '(+Var +TextField) '*QR-Code 60) ) ) )

# vi:et:ts=3:sw=3
