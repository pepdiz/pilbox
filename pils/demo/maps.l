# 15sep17abu
# (c) Software Lab. Alexander Burger

(menu "GPS Position"
   (form NIL
      (<h3> "fh" "GPS Position")
      (<tab>
         ("Location"
            (<grid> 3
               "Latitude" (gui '(+Var +LatField) '*Latitude 11)
               (gui '(+Button) "Get my location"
                  '(let G (gps)
                     (setq *Latitude (car G)  *Longitude (cdr G)) ) )
               "Longitude" (gui '(+Var +LonField) '*Longitude 11) ) )
         ("OpenStreetMap"
            (<h4> NIL "For unknown reasons Openlayers don't work")
            (<osm> *Latitude *Longitude 12)
            (<poi> *Latitude *Longitude
               "@img/go.png" "0.1" "1.0"
               "Here" -20 "black" ) )
         ("GoogleMaps"
            (<google> *Latitude *Longitude "100%" 400) ) ) ) )

# vi:et:ts=3:sw=3
