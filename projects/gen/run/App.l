# 10sep17abu
# (c) Software Lab. Alexander Burger

"Generic PicoLisp App"

(load "@lib/misc.l" "@lib/btree.l" "@lib/db.l" "@lib/pilog.l")

# Generic PilBox App
(allowed ()
   "!pbHome" "@lib.css" "@lib/phone.css" "!pbSettings" "!pbList" "!pbRepl" )

(scl 6)

(load
   "@lib/http.l" "@lib/xhtml.l" "@lib/form.l" "@lib/canvas.l"
   "@lib/android.l" "@lib/gis.l" )

(symbols '(pico gis android))

(conc (last repl)
   '((gui '(+Button) "Clear Cache" '(clearCache))) )

(de *Locales
   ("English" NIL)
   ("English (US)" "US")
   ("English (UK)" "UK")
   ("Deutsch (DE)" "DE" . "de")
   ("Deutsch (CH)" "CH" . "ch")
   ("Español (ES)" "ES" . "es")
   ("Español (AR)" "AR" . "ar")
   ("Català (ES)" "ES" . "ca")
   ("Français (FR)" "FR" . "fr")
   ("λληνικά (GR)" "GR" . "gr")
   ("Norsk" "NO" . "no")
   ("Русский" "RU" . "ru")
   ("Svenska" "SE" . "sv")
   ("日本語" "JP" . "jp") )

(de menu (Ttl . Prg)
   (unless *SesId (forbidden))
   (action
      (html 0 Ttl *Css NIL
         (<ping> 2)
         (<layout> T
            ((25 20 "display: table-cell; text-align: center;")
               (<div> @
                  (<img> *PbLogo "Logo"
                     (or (cdr (assoc *Url *PbHome)) (caar *PbHome)) ) )
               ((50 20 "center")
                  (<div> @
                     (run *PbHeader) )
                  ((25 20 "display: table-cell; text-align: center;")
                     (<div> @
                        (<img> "@img/settings.png" "Settings"
                           (if (= *Url *PbSettings)
                              "!pbHome"
                              (pack *PbSettings "?*Tab=+1") )
                           ,"Settings" ) ) ) ) )
            ((0 0 'main)
               (<div> @
                  (run Prg 1) ) ) ) ) ) )

(de pbRepl ()
   (menu "PicoLisp REPL"
      (<h3> "fh" "PicoLisp REPL")
      (repl) ) )

(de pbSettings ()
   (menu ,"Settings"
      (form NIL
         (<h3> "fh" ,"Settings")
         (<h4> "fh" "PilBox Version " (in "Version" (echo)))
         (<tab>
            (,"Language" (localeSettings))
            ("PILs"
               (gui '(+Init +Chart)
                  (sort
                     (extract
                        '((F) (and (pre? "PIL-" F) (list NIL F)))
                        (dir) ) )
                  2 )
               (<table> 'chart NIL '((btn) NIL)
                  (do 12
                     (<row> (alternating)
                        (gui 1 '(+Checkbox))
                        (gui 2 '(+Url +TextField)
                           '((F) (pack "!pbList?" F)) ) ) ) )
               (<spread>
                  (scroll 12)
                  (gui '(+Able +Button)
                     '(find car (: home chart 1 data))
                     ,"Delete"
                     '(let C (: home chart 1)
                        (for L (val> C)
                           (when (car L)
                              (set> C (delete L (val> C)))
                              (in (cadr L)
                                 (while (line T)
                                    (call "rm" "-rf" @) ) )
                              (call "rm" (cadr L)) ) ) ) ) ) ) ) ) ) )

(de localeSettings ()
   (<table> NIL NIL NIL
      (<row> NIL
         (gui '(+Init +Chg +Fmt +Radio)
            (readLocale)
            '((X)
               (apply locale "*Locs" (car X) (cdr X))
               (out "Locale" (println X)) )
            '((X) (car (rassoc X *Locales)))
            '((R) (cdr (assoc R *Locales)))
            NIL
            (caar *Locales) )
         (ht:Prin (caar *Locales)) )
      (for (I . L) (cdr *Locales)
         (<row> NIL
            (gui '(+Radio) (- I) (car L))
            (ht:Prin (car L)) ) ) ) )

(de readLocale ()
   (and
      (info "Locale")
      (prog1
         (in "Locale" (read))
         (apply locale "*Locs" (car @) (cdr @)) ) ) )

(de pbList (File)
   (menu File
      (form NIL
         (<h3> "fh" File)
         (<pre> NIL
            (in File (while (line T) (prinl @))) ) ) ) )

(de pilbox (Url Path . Head)
   (when (cdar *PbHome)
      (setq *PbHome (cons (cons Url "!pbHome") '("!pbHome" . "!pbRepl"))) )
   (let F (pack Path "lib.css")
      (setq *Css
         (if (info F)
            (list "@lib.css" "@lib/phone.css" F)
            '("@lib.css" "@lib/phone.css") ) ) )
   (let F (pack Path "logo.png")
      (setq *PbLogo (if (info F) F "@img/logo.png")) )
   (let F (pack Path "settings.l")
      (setq *PbSettings (if (info F) F "!pbSettings")) )
   (and Head (setq *PbHeader @)) )

(de pbHome (Uuid)
   (when (app)
      (or (= Uuid *Uuid) (bye)) )
   (setq
      *PbHome '(("!pbHome" . "!pbRepl"))
      *Css '("@lib.css" "@lib/phone.css")
      *PbLogo "@img/logo.png"
      *PbSettings "!pbSettings"
      *PbHeader '((<h3> "fh" "PilBox") (<h4> "fh" "PicoLisp App")) )
   (let Lst
      (sort
         (make
            (for D (dir)
               (let F (pack D "/App.l")
                  (and
                     (info F)
                     (in F (read))
                     (link (cons @ F)) ) ) ) ) )
      (ifn (and Uuid Lst (not (cdr Lst)))
         (menu "PilBox"
            (<layout> T
               ((20 NIL)
                  (<div> @)
                  ((60 15) ("button"))
                  ((60 15) ("button"))
                  ((60 15) ("button"))
                  ((60 15) ("button"))
                  ((60 15) ("button"))
                  ((60 15) ("button"))
                  ((60 15) ("button")) ) ) )
         (setq *PbHome (list (cons (cdar Lst))))
         (loadUrl (baseHRef) *SesId (cdar Lst)) ) ) )

(de "button" ()
   (<div> @
      (and Lst (<button> (cdar Lst) (caar (++ Lst)))) ) )


# Init application
(setq "*Locs"
   (extract
      '((D)
         (when (info (pack D "/App.l"))
            (allow (pack D "/") T) )
         (and (info (pack D "/loc")) (pack D "/loc/")) )
      (dir) ) )
(readLocale)

# Start application
(gc 2)
(out "PID" (prinl *Pid))
(server (format (sys "PORT")) "!pbHome")
(wait)

# vi:et:ts=3:sw=3
