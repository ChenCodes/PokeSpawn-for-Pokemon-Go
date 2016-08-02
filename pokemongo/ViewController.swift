//
//  ViewController.swift
//  pokemongo
//
//  Created by Angel Lim on 7/11/16.
//  Copyright © 2016 Angel Lim. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Firebase
import SCLAlertView
import AutocompleteField
import SearchTextField



class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, GMSMapViewDelegate {
    var customPokemonAddField: UITextField?
    
    let locationManager = CLLocationManager()
    var ref: FIRDatabaseReference?
    var mapView: GMSMapView?
    var mySearchTextField: SearchTextField?
    let appearance = SCLAlertView.SCLAppearance(
        showCircularIcon: true,
        shouldAutoDismiss: false,
        showCloseButton: false)
        
    
    var lastMarkerTapped: GMSMarker?
    
    var validity = false
    var enteredString = ""
    var justCaptured = "none"
    
    var pokemon = ["abra", "aerodactyl", "articuno", "bellsprout", "bulbasaur", "caterpie", "chansey", "charmander", "clefairy", "cubone", "diglett", "doduo", "dratini", "drowsee", "eevee", "ekans", "electabuzz", "exeggcute", "farfetchd", "gastly", "geodude", "goldeen", "grimer", "growlithe", "hitmonchan", "hitmonlee", "horsea", "jigglypuff", "jynx", "kabuto", "kangaskhan", "krabby", "lapras", "lickitung", "machop", "magikarp", "magmar", "magnemite", "mankey", "meowth", "mewtwo", "metapod", "moltres", "mr.mime", "nidoran-f", "nidoran-m", "oddish", "omanyte", "onix", "paras", "pidgey", "pikachu", "polywag", "ponyta", "porygon", "psyduck", "rattata", "rhyhorn", "sandshrew", "scyther", "seel", "shellder", "slowpoke", "snorlax", "zapdos", "spearow", "squirtle", "staryu", "tangela", "tentacool", "venonat", "voltrob", "vulpix", "weedle", "weezing", "zubat", "butterfree", "ditto", "mew", "dragonite", "tauros", "pinsir", "koffing", "machop", "beedrill", "kakuna", "pigeot", "pidgeotto", "raticate", "fearow", "arbok", "raichu", "dragonair", "kabutops", "omastar", "flareon", "jolteon", "vaporeon", "gyarados", "starmie", "seaking", "seadra", "rhydon", "marowak", "exeggutor", "electrode", "kingler", "hypno", "gengar", "haunter", "cloyster", "muk", "dewgong", "dodrio", "magneton", "slowbro", "rapidash", "golem", "graveler", "tentacruel", "victreebel", "weepinbell", "machamp", "machoke", "alakazam", "kadabra", "polywrath", "polywhirl", "arcanine", "primeape", "golduck", "persian", "dugtrio", "venomoth", "parasect", "vileplume", "gloom", "golbat", "wigglytuff", "ninetales", "clefable", "nidoking", "nidorino", "nidoqueen", "nidorina", "sandslash", "charizard", "charmeleon", "venusaur", "ivysaur", "wartotle", "blastoise", "pokestop", "pokegym"]
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("return")
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        self.ref = FIRDatabase.database().reference()
        //ref?.keepSynced(true)
        
        // listener for new markers being added
        ref!.child("markers").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in

            let lat = snapshot.value!["latitude"] as! Double
            let lon = snapshot.value!["longitude"] as! Double
            let pokemonName = snapshot.value!["pokemon"] as! String
            let timestamp = snapshot.value!["timestamp"] as! Double
            self.addMarkerToMap(lat, lon: lon, name: pokemonName, timestamp: timestamp, dbid: snapshot.key)
        })
        
        
        // listen for makers upvotes that are getting changed
//        ref!.child("markers").observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
//            
//            print("upvote changed")
//            
//            let upvotes: Int = Int(snapshot.value!["upvotes"] as! String)!
//            print("here")
//            print(upvotes)
//            
//            
//
//        })
        
        
        // in case we delete DB
        ref!.observeEventType(.ChildRemoved, withBlock: { (snapshot) -> Void in
            
            self.rerenderMapWithPokemon()
            
            
        })
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func rerenderMapWithPokemon() {
        self.mapView?.clear()
        
        ref!.child("markers").observeEventType(.Value, withBlock: { (snapshot) -> Void in
            
            for elem in snapshot.children {
                let lat = elem.value["latitude"] as! Double
                let lon = elem.value["longitude"] as! Double
                let searchName = elem.value["pokemon"] as! String
                let timestamp = elem.value["timestamp"] as! Double
                self.addMarkerToMap(lat, lon: lon, name: searchName, timestamp: timestamp, dbid: elem.key)
            }
            
            
        })
        

        
    }
    
    func initGoogleMaps(lat: Double, lon: Double) {
        // google maps stuff
        
        let camera = GMSCameraPosition.cameraWithLatitude(lat,
                                                          longitude: lon, zoom: 15)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.consumesGesturesInView = false
        self.view = mapView
        
        self.mapView = mapView
        self.mapView?.delegate = self
        
        
        
        let placeholder = NSAttributedString(string: "Search", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        mySearchTextField = SearchTextField(frame: CGRectMake(10, 30, screenWidth * 15/20, 40))
        mySearchTextField!.theme.fontColor = UIColor.blackColor()
        mySearchTextField!.attributedPlaceholder = placeholder
        
        let item1 = SearchTextFieldItem(title: "Bulbasaur", subtitle: "Type: Grass/Poison", image: UIImage(named: "bulbasaur"))
        let item2 = SearchTextFieldItem(title: "Charmander", subtitle: "Type: Fire", image: UIImage(named: "charmander"))
        let item3 = SearchTextFieldItem(title: "Squirtle", subtitle: "Type: Water", image: UIImage(named: "squirtle"))
        let item4 = SearchTextFieldItem(title: "Caterpie", subtitle: "Type: Bug", image: UIImage(named: "caterpie"))
        let item5 = SearchTextFieldItem(title: "Metapod", subtitle: "Type: Bug", image: UIImage(named: "metapod"))
        let item6 = SearchTextFieldItem(title: "Weedle", subtitle: "Type: Bug", image: UIImage(named: "weedle"))
        let item7 = SearchTextFieldItem(title: "Pidgey", subtitle: "Type: Normal", image: UIImage(named: "pidgey"))
        let item8 = SearchTextFieldItem(title: "Rattata", subtitle: "Type: Normal", image: UIImage(named: "rattata"))
        let item9 = SearchTextFieldItem(title: "Spearow", subtitle: "Type: Flying", image: UIImage(named: "spearow"))
        let item10 = SearchTextFieldItem(title: "Ekans", subtitle: "Type: Poison", image: UIImage(named: "ekans"))
        let item11 = SearchTextFieldItem(title: "Pikachu", subtitle: "Type: Electric", image: UIImage(named: "pikachu"))
        let item12 = SearchTextFieldItem(title: "Sandshrew", subtitle: "Type: Ground", image: UIImage(named: "sandshrew"))
        let item13 = SearchTextFieldItem(title: "Nidoran-F", subtitle: "Type: Poison", image: UIImage(named: "nidoran-f"))
        let item14 = SearchTextFieldItem(title: "Nidoran-M", subtitle: "Type: Poison", image: UIImage(named: "nidoran-m"))
        let item15 = SearchTextFieldItem(title: "Clefairy", subtitle: "Type: Fairy", image: UIImage(named: "clefairy"))
        let item16 = SearchTextFieldItem(title: "Vulpix", subtitle: "Type: Water", image: UIImage(named: "squirtle"))
        //        let item17 = SearchTextFieldItem(title: "Squirtle", subtitle: "Type: Fire", image: UIImage(named: "vulpix"))
        let item18 = SearchTextFieldItem(title: "Jigglypuff", subtitle: "Type: Normal/Fairy", image: UIImage(named: "jigglypuff"))
        let item19 = SearchTextFieldItem(title: "Zubat", subtitle: "Type: Poison/Flying", image: UIImage(named: "zubat"))
        let item20 = SearchTextFieldItem(title: "Oddish", subtitle: "Type: Grass/Poison", image: UIImage(named: "oddish"))
        let item21 = SearchTextFieldItem(title: "Paras", subtitle: "Type: Bug/Grass", image: UIImage(named: "paras"))
        let item22 = SearchTextFieldItem(title: "Venonat", subtitle: "Type: Bug/Poison", image: UIImage(named: "venonat"))
        let item23 = SearchTextFieldItem(title: "Diglett", subtitle: "Type: Ground", image: UIImage(named: "diglett"))
        let item24 = SearchTextFieldItem(title: "Meowth", subtitle: "Type: Normal", image: UIImage(named: "meowth"))
        let item25 = SearchTextFieldItem(title: "Psyduck", subtitle: "Type: Water", image: UIImage(named: "psyduck"))
        let item26 = SearchTextFieldItem(title: "Mankey", subtitle: "Type: Fighting", image: UIImage(named: "mankey"))
        let item27 = SearchTextFieldItem(title: "Growlithe", subtitle: "Type: Fire", image: UIImage(named: "growlithe"))
        let item28 = SearchTextFieldItem(title: "Poliwag", subtitle: "Type: Water", image: UIImage(named: "poliwag"))
        let item29 = SearchTextFieldItem(title: "Abra", subtitle: "Type: Psychic", image: UIImage(named: "abra"))
        let item30 = SearchTextFieldItem(title: "Machop", subtitle: "Type: Fighting", image: UIImage(named: "machop"))
        let item31 = SearchTextFieldItem(title: "Bellsprout", subtitle: "Type: Grass/Poison", image: UIImage(named: "bellsprout"))
        let item32 = SearchTextFieldItem(title: "Tentacool", subtitle: "Type: Water/Poison", image: UIImage(named: "tentacool"))
        let item33 = SearchTextFieldItem(title: "Geodude", subtitle: "Type: Rock/Ground", image: UIImage(named: "geodude"))
        let item34 = SearchTextFieldItem(title: "Ponyta", subtitle: "Type: Fire", image: UIImage(named: "ponyta"))
        let item35 = SearchTextFieldItem(title: "Slowpoke", subtitle: "Type: Water/Psychic", image: UIImage(named: "slowpoke"))
        let item36 = SearchTextFieldItem(title: "Magnemite", subtitle: "Type: Electric/Steel", image: UIImage(named: "magnemite"))
        let item37 = SearchTextFieldItem(title: "Farfetch'd", subtitle: "Type: Normal/Flying", image: UIImage(named: "farfetchd"))
        let item38 = SearchTextFieldItem(title: "Doduo", subtitle: "Type: Normal/Flying", image: UIImage(named: "doduo"))
        let item39 = SearchTextFieldItem(title: "Seel", subtitle: "Type: Water", image: UIImage(named: "seel"))
        let item40 = SearchTextFieldItem(title: "Shellder", subtitle: "Type: Water", image: UIImage(named: "shellder"))
        let item41 = SearchTextFieldItem(title: "Gastly", subtitle: "Type: Ghost/Poison", image: UIImage(named: "gastly"))
        let item42 = SearchTextFieldItem(title: "Onix", subtitle: "Type: Rock/Ground", image: UIImage(named: "onix"))
        let item43 = SearchTextFieldItem(title: "Drowzee", subtitle: "Type: Psychic", image: UIImage(named: "drowzee"))
        let item44 = SearchTextFieldItem(title: "Krabby", subtitle: "Type: Water", image: UIImage(named: "krabby"))
        let item45 = SearchTextFieldItem(title: "Voltorb", subtitle: "Type: Electric", image: UIImage(named: "voltorb"))
        let item46 = SearchTextFieldItem(title: "Exeggcute", subtitle: "Type: Grass/Psychic", image: UIImage(named: "exeggcute"))
        let item47 = SearchTextFieldItem(title: "Cubone", subtitle: "Type: Ground", image: UIImage(named: "cubone"))
        let item48 = SearchTextFieldItem(title: "Hitmonlee", subtitle: "Type: Fighting", image: UIImage(named: "hitmonlee"))
        let item49 = SearchTextFieldItem(title: "Hitmonchan", subtitle: "Type: Fighting", image: UIImage(named: "hitmonchan"))
        let item50 = SearchTextFieldItem(title: "Lickitung", subtitle: "Type: Normal", image: UIImage(named: "lickitung"))
        let item51 = SearchTextFieldItem(title: "Koffing", subtitle: "Type: Poison", image: UIImage(named: "koffing"))
        let item52 = SearchTextFieldItem(title: "Rhyhorn", subtitle: "Type: Ground/Rock", image: UIImage(named: "rhyhorn"))
        let item53 = SearchTextFieldItem(title: "Chansey", subtitle: "Type: Normal", image: UIImage(named: "chansey"))
        let item54 = SearchTextFieldItem(title: "Tangela", subtitle: "Type: Grass", image: UIImage(named: "tangela"))
        let item55 = SearchTextFieldItem(title: "Kangashkan", subtitle: "Type: Normal", image: UIImage(named: "kangaskhan"))
        let item56 = SearchTextFieldItem(title: "Horsea", subtitle: "Type: Water", image: UIImage(named: "horsea"))
        let item57 = SearchTextFieldItem(title: "Goldeen", subtitle: "Type: Water", image: UIImage(named: "goldeen"))
        let item58 = SearchTextFieldItem(title: "Mr.Mime", subtitle: "Type: Psychic/Fairy", image: UIImage(named: "mrmime"))
        let item59 = SearchTextFieldItem(title: "Scyther", subtitle: "Bug/Flying", image: UIImage(named: "scyther"))
        let item60 = SearchTextFieldItem(title: "Jynx", subtitle: "Type: Ice/Psychic", image: UIImage(named: "jynx"))
        let item61 = SearchTextFieldItem(title: "Electabuzz", subtitle: "Type: Electric", image: UIImage(named: "electabuzz"))
        let item62 = SearchTextFieldItem(title: "Magmar", subtitle: "Type: Fire", image: UIImage(named: "magmar"))
        let item63 = SearchTextFieldItem(title: "Pinsir", subtitle: "Type: Bug", image: UIImage(named: "pinsir"))
        let item64 = SearchTextFieldItem(title: "Tauros", subtitle: "Type: Normal", image: UIImage(named: "tauros"))
        let item65 = SearchTextFieldItem(title: "Magikarp", subtitle: "Type: Water", image: UIImage(named: "magikarp"))
        let item66 = SearchTextFieldItem(title: "Lapras", subtitle: "Type: Water/Ice", image: UIImage(named: "lapras"))
        let item67 = SearchTextFieldItem(title: "Ditto", subtitle: "Type: Normal", image: UIImage(named: "ditto"))
        let item68 = SearchTextFieldItem(title: "Eevee", subtitle: "Type: Normal", image: UIImage(named: "eevee"))
        let item69 = SearchTextFieldItem(title: "Porygon", subtitle: "Type: Normal", image: UIImage(named: "porygon"))
        let item70 = SearchTextFieldItem(title: "Omanyte", subtitle: "Type: Rock/Water", image: UIImage(named: "omanyte"))
        let item71 = SearchTextFieldItem(title: "Kabuto", subtitle: "Type: Rock/Water", image: UIImage(named: "kabuto"))
        let item72 = SearchTextFieldItem(title: "Aerodactyl", subtitle: "Type: Rock/Flying", image: UIImage(named: "aerodactyl"))
        let item73 = SearchTextFieldItem(title: "Snorlax", subtitle: "Type: Normal", image: UIImage(named: "snorlax"))
        let item74 = SearchTextFieldItem(title: "Articuno", subtitle: "Type: Ice/Flying", image: UIImage(named: "articuno"))
        let item75 = SearchTextFieldItem(title: "Zapdos", subtitle: "Type: Electric/Flying", image: UIImage(named: "zapdos"))
        let item76 = SearchTextFieldItem(title: "Moltres", subtitle: "Type: Fire/Flying", image: UIImage(named: "moltres"))
        let item77 = SearchTextFieldItem(title: "Dratini", subtitle: "Type: Dragon", image: UIImage(named: "dratini"))
        let item78 = SearchTextFieldItem(title: "Kakuna", subtitle: "Type: Bug", image: UIImage(named: "kakuna"))
        //        let item79 = SearchTextFieldItem(title: "Beedrill", subtitle: "Type: Bug", image: UIImage(named: "beedrill"))
        let item80 = SearchTextFieldItem(title: "Pidgeotto", subtitle: "Type: Normal/Flying", image: UIImage(named: "pidgeotto"))
        let item81 = SearchTextFieldItem(title: "Pidgeot", subtitle: "Type: Normal/Flying", image: UIImage(named: "pidgeot"))
        let item82 = SearchTextFieldItem(title: "Raticate", subtitle: "Type: Normal", image: UIImage(named: "raticate"))
        let item83 = SearchTextFieldItem(title: "Fearow", subtitle: "Type: Flying", image: UIImage(named: "fearow"))
        let item84 = SearchTextFieldItem(title: "Arbok", subtitle: "Type: Normal/Flying", image: UIImage(named: "arbok"))
        let item85 = SearchTextFieldItem(title: "Sandslash", subtitle: "Type: Ground", image: UIImage(named: "sandslash"))
        let item86 = SearchTextFieldItem(title: "Nidorina", subtitle: "Type: Poison", image: UIImage(named: "nidorina"))
        let item87 = SearchTextFieldItem(title: "Nidoqueen", subtitle: "Type: Poison", image: UIImage(named: "nidoqueen"))
        let item88 = SearchTextFieldItem(title: "Nidorino", subtitle: "Type: Poison", image: UIImage(named: "nidorino"))
        let item89 = SearchTextFieldItem(title: "Nidoking", subtitle: "Type: Poison", image: UIImage(named: "nidoking"))
        let item90 = SearchTextFieldItem(title: "Clefable", subtitle: "Type: Fairy", image: UIImage(named: "clefable"))
        let item91 = SearchTextFieldItem(title: "Ninetales", subtitle: "Type: Fire", image: UIImage(named: "ninetales"))
        let item92 = SearchTextFieldItem(title: "Wigglytuff", subtitle: "Type: Normal/Fairy", image: UIImage(named: "wigglytuff"))
        let item93 = SearchTextFieldItem(title: "Golbat", subtitle: "Type: Poison/Flying", image: UIImage(named: "golbat"))
        let item94 = SearchTextFieldItem(title: "Gloom", subtitle: "Type: Grass/Poison", image: UIImage(named: "gloom"))
        let item95 = SearchTextFieldItem(title: "Vileplume", subtitle: "Type: Grass/Poison", image: UIImage(named: "vileplume"))
        let item96 = SearchTextFieldItem(title: "Parasect", subtitle: "Type: Bug/Grass", image: UIImage(named: "parasect"))
        let item97 = SearchTextFieldItem(title: "Venomoth", subtitle: "Type: Bug/Poison", image: UIImage(named: "venomoth"))
        let item98 = SearchTextFieldItem(title: "Dugtrio", subtitle: "Type: Ground", image: UIImage(named: "dugtrio"))
        let item99 = SearchTextFieldItem(title: "Persian", subtitle: "Type: Normal", image: UIImage(named: "persian"))
        let item100 = SearchTextFieldItem(title: "Golduck", subtitle: "Type: Water", image: UIImage(named: "golduck"))
        let item101 = SearchTextFieldItem(title: "Primeape", subtitle: "Type: Fighting", image: UIImage(named: "primeape"))
        let item102 = SearchTextFieldItem(title: "Arcanine", subtitle: "Type: Fire", image: UIImage(named: "arcanine"))
        let item103 = SearchTextFieldItem(title: "Polywhirl", subtitle: "Type: Water", image: UIImage(named: "polywhirl"))
        let item104 = SearchTextFieldItem(title: "Polywrath", subtitle: "Type: Water", image: UIImage(named: "polywrath"))
        let item105 = SearchTextFieldItem(title: "Kadabra", subtitle: "Type: Psychic", image: UIImage(named: "kadabra"))
        let item106 = SearchTextFieldItem(title: "Alakazam", subtitle: "Type: Psychic", image: UIImage(named: "alakazam"))
        let item107 = SearchTextFieldItem(title: "Machoke", subtitle: "Type: Fighting", image: UIImage(named: "machoke"))
        let item108 = SearchTextFieldItem(title: "Machamp", subtitle: "Type: Fighting", image: UIImage(named: "machamp"))
        let item109 = SearchTextFieldItem(title: "Weepinbell", subtitle: "Type: Grass/Poison", image: UIImage(named: "weepinbell"))
        let item110 = SearchTextFieldItem(title: "Beedrill", subtitle: "Type: Bug", image: UIImage(named: "beedrill"))
        let item111 = SearchTextFieldItem(title: "Victreebel", subtitle: "Type: Grass/Poison", image: UIImage(named: "victreebel"))
        let item112 = SearchTextFieldItem(title: "Tentacruel", subtitle: "Type: Water/Poison", image: UIImage(named: "tentacruel"))
        let item113 = SearchTextFieldItem(title: "Graveler", subtitle: "Type: Rock/Ground", image: UIImage(named: "graveler"))
        let item114 = SearchTextFieldItem(title: "Golem", subtitle: "Type: Rock/Ground", image: UIImage(named: "golem"))
        let item115 = SearchTextFieldItem(title: "Rapidash", subtitle: "Type: Fire", image: UIImage(named: "rapidash"))
        let item116 = SearchTextFieldItem(title: "Slowbro", subtitle: "Type: Water/Psychic", image: UIImage(named: "slowbro"))
        let item117 = SearchTextFieldItem(title: "Magneton", subtitle: "Type: Electric/Steel", image: UIImage(named: "magneton"))
        let item118 = SearchTextFieldItem(title: "Dodrio", subtitle: "Type: Normal/Flying", image: UIImage(named: "dodrio"))
        let item119 = SearchTextFieldItem(title: "Dewgong", subtitle: "Type: Water/Ice", image: UIImage(named: "dewgong"))
        let item120 = SearchTextFieldItem(title: "Muk", subtitle: "Type: Poison", image: UIImage(named: "muk"))
        let item121 = SearchTextFieldItem(title: "Cloyster", subtitle: "Type: Water/Ice", image: UIImage(named: "cloyster"))
        let item122 = SearchTextFieldItem(title: "Haunter", subtitle: "Type: Ghost/Poison", image: UIImage(named: "haunter"))
        let item123 = SearchTextFieldItem(title: "Gengar", subtitle: "Type: Ghost/Poison", image: UIImage(named: "gengar"))
        let item124 = SearchTextFieldItem(title: "Hypno", subtitle: "Type: Psychic", image: UIImage(named: "hypno"))
        let item125 = SearchTextFieldItem(title: "Kingler", subtitle: "Type: Water", image: UIImage(named: "kingler"))
        let item126 = SearchTextFieldItem(title: "Electrode", subtitle: "Type: Electric", image: UIImage(named: "electrode"))
        let item127 = SearchTextFieldItem(title: "Exeggutor", subtitle: "Type: Grass/Psychic", image: UIImage(named: "exeggutor"))
        let item128 = SearchTextFieldItem(title: "Marowak", subtitle: "Type: Ground", image: UIImage(named: "marowak"))
        let item129 = SearchTextFieldItem(title: "Weezing", subtitle: "Type: Poison", image: UIImage(named: "weezing"))
        let item130 = SearchTextFieldItem(title: "Rhydon", subtitle: "Type: Ground/Rock", image: UIImage(named: "rhydon"))
        let item131 = SearchTextFieldItem(title: "Seadra", subtitle: "Type: Water", image: UIImage(named: "seadra"))
        let item132 = SearchTextFieldItem(title: "Seaking", subtitle: "Type: Water", image: UIImage(named: "seaking"))
        let item133 = SearchTextFieldItem(title: "Starmie", subtitle: "Type: Water", image: UIImage(named: "starmie"))
        let item134 = SearchTextFieldItem(title: "Gyarados", subtitle: "Type: Water", image: UIImage(named: "gyarados"))
        let item135 = SearchTextFieldItem(title: "Vaporeon", subtitle: "Type: Water", image: UIImage(named: "vaporeon"))
        let item136 = SearchTextFieldItem(title: "Jolteon", subtitle: "Type: Electric", image: UIImage(named: "jolteon"))
        let item137 = SearchTextFieldItem(title: "Flareon", subtitle: "Type: Fire", image: UIImage(named: "flareon"))
        let item138 = SearchTextFieldItem(title: "Omastar", subtitle: "Type: Rock/Water", image: UIImage(named: "omastar"))
        let item139 = SearchTextFieldItem(title: "Kabutops", subtitle: "Type: Rock/Water", image: UIImage(named: "kabutops"))
        let item140 = SearchTextFieldItem(title: "Dragonair", subtitle: "Type: Dragon", image: UIImage(named: "dragonair"))
        let item141 = SearchTextFieldItem(title: "Mewtwo", subtitle: "Type: Psychic", image: UIImage(named: "mewtwo"))
        let item142 = SearchTextFieldItem(title: "Blastoise", subtitle: "Type: Water", image: UIImage(named: "blastoise"))
        let item143 = SearchTextFieldItem(title: "Wartortle", subtitle: "Type: Water", image: UIImage(named: "wartortle"))
        let item144 = SearchTextFieldItem(title: "Venusaur", subtitle: "Type: Grass/Poison", image: UIImage(named: "venusaur"))
        let item145 = SearchTextFieldItem(title: "Ivysaur", subtitle: "Type: Grass/Poison", image: UIImage(named: "ivysaur"))
        let item146 = SearchTextFieldItem(title: "Charmeleon", subtitle: "Type: Fire", image: UIImage(named: "charmeleon"))
        let item147 = SearchTextFieldItem(title: "Charizard", subtitle: "Type: Fire", image: UIImage(named: "charizard"))
        let item148 = SearchTextFieldItem(title: "Raichu", subtitle: "Type: Electric", image: UIImage(named: "raichu"))
        let item149 = SearchTextFieldItem(title: "PokeStop", subtitle: "Type: Stop", image: UIImage(named: "pokestop"))
        let item150 = SearchTextFieldItem(title: "PokeGym", subtitle: "Type: Gym", image: UIImage(named: "pokegym"))
        
        mySearchTextField!.filterItems([item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12, item13, item14, item15, item16, item18, item19, item20, item21, item22, item23, item24, item25, item26, item27, item28,
            item29, item30, item31, item32, item33, item34, item35, item36, item37, item38, item39, item40, item41, item42, item43, item44, item45, item46, item47, item48, item49, item50, item51, item52, item53, item54, item55, item56, item57, item58, item59, item60, item61, item62, item63, item64, item65, item66, item67, item68, item69, item70, item71, item72, item73, item74, item75, item76, item77, item78, item80, item81, item82, item83, item84, item85, item86, item87, item88, item89, item90, item91, item92, item93, item94, item95, item96, item97, item98, item99, item100, item101, item102, item103, item104, item105, item106, item107, item108, item109, item110, item111, item112, item113, item114, item115, item116, item117, item118, item119, item120, item121, item122, item123, item124, item125, item126, item127, item128, item129, item130, item131, item132, item133, item134, item135, item136, item137, item138, item139, item140, item141, item142, item143, item144, item145, item146, item147, item148, item149, item150])
        
        mySearchTextField!.itemSelectionHandler = {item in
            //Chosen Pokemon will be self.mySearchTextField!
            self.mySearchTextField!.text = item.title
        }
        mySearchTextField!.maxNumberOfResults = 7
        mySearchTextField!.theme.cellHeight = 50
        mySearchTextField!.backgroundColor = UIColor.whiteColor()
        mySearchTextField!.clearButtonMode = .WhileEditing
        mySearchTextField!.borderStyle = UITextBorderStyle.RoundedRect
        
        self.view.addSubview(mySearchTextField!)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    let lat = Double((manager.location?.coordinate.latitude)!)
                    let lon = Double((manager.location?.coordinate.longitude)!)
                    initGoogleMaps(lat, lon: lon)
                    
                    let screenWidth = UIScreen.mainScreen().bounds.width
                    let screenHeight = UIScreen.mainScreen().bounds.height
                    
                    let btn = UIButton(type: UIButtonType.Custom) as UIButton
                    btn.setImage(UIImage(named: "pokemonLog.png"), forState: UIControlState.Normal)
                    btn.frame = CGRectMake(screenWidth * 80/100, screenHeight * 75/100, 80, 80)
                    btn.addTarget(self, action: "clickMe:", forControlEvents: UIControlEvents.TouchUpInside)
                    btn.layer.masksToBounds = false
                    btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).CGColor
                    btn.layer.shadowOpacity = 1.0
                    btn.layer.shadowRadius = 0
                    btn.layer.shadowOffset = CGSizeMake(0, 2.0)
                    self.view.addSubview(btn)
                    
                    let done = UIButton(type: UIButtonType.Custom) as UIButton
                    done.setImage(UIImage(named: "caughtButton.png"), forState: UIControlState.Normal)
                    done.layer.masksToBounds = false
                    done.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).CGColor
                    done.layer.shadowOpacity = 1.0
                    done.layer.shadowRadius = 0
                    done.layer.shadowOffset = CGSizeMake(0, 2.0)
                    done.frame = CGRectMake(screenWidth * 80/100, 20, 60, 60)
                    done.addTarget(self, action: "donePressed:", forControlEvents: UIControlEvents.TouchUpInside)
                    self.view.addSubview(done)
                    
                    let dropBuilding = UIButton(type: UIButtonType.Custom) as UIButton
                    dropBuilding.setImage(UIImage(named: "pokestop.png"), forState: UIControlState.Normal)
                    dropBuilding.layer.masksToBounds = false
                    dropBuilding.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).CGColor
                    dropBuilding.layer.shadowOpacity = 1.0
                    dropBuilding.layer.shadowRadius = 0
                    dropBuilding.layer.shadowOffset = CGSizeMake(0, 2.0)
                    dropBuilding.frame = CGRectMake(screenWidth * 80/100, screenHeight * 30/100, 60, 60)
                    dropBuilding.addTarget(self, action: "dropStop:", forControlEvents: UIControlEvents.TouchUpInside)
                    self.view.addSubview(dropBuilding)
                    
                    
                    
                    
                    let alertButton = UIButton(type: UIButtonType.Custom) as UIButton
                    alertButton.setImage(UIImage(named: "yesAlert.png"), forState: UIControlState.Normal)
                    alertButton.layer.masksToBounds = false
                    alertButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).CGColor
                    alertButton.layer.shadowOpacity = 1.0
                    alertButton.layer.shadowRadius = 0
                    alertButton.layer.shadowOffset = CGSizeMake(0, 2.0)
                    alertButton.frame = CGRectMake(screenWidth * 80/100, screenHeight * 20/100, 60, 60)
                    alertButton.addTarget(self, action: "alertPressed:", forControlEvents: UIControlEvents.TouchUpInside)
                    self.view.addSubview(alertButton)
                    
                    
                } else {
                    print("inner fail")
                }
            } else {
                print("outer fail")
            }
        }
    }
    
    func dropStop(sender: UIButton!) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Drop Pokestop") {
            self.addPokemonMarkerToFirebase("pokestop")
        }
        alertView.addButton("Drop Pokegym") {
            self.addPokemonMarkerToFirebase("pokegym")
        }
        alertView.addButton("Cancel", backgroundColor: UIColor.redColor()) {
            alertView.hideView()
        }
        alertView.showSuccess("", subTitle: "Which marker would you like to drop?")

    
        
    }
    
    
    
    
    //This means the alert button was pressed, we need to open up an alert view with the right information.
    func alertPressed(sender: UIButton!) {
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Zoom to Location", target:self, selector:Selector("zoomLocation"))
        alertView.addButton("Cancel", backgroundColor: UIColor.redColor()) {
            alertView.hideView()
        }
        alertView.showWarning("Mewtwo was found!", subTitle: "It was found 100 yards away.") // Warning
    }
    
    func zoomLocation() {
        print("zoomed")
    }
    
    
    
    // MARK: entering a new pokemon function
    func clickMe(sender: UIButton!) {
        dismissButtons()
        let alertView = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "caughtPokemonIcon") //Replace the IconImage text with the image name


        let txt = AutocompleteField(frame: CGRectMake(10, 10, 200, 40), suggestions: pokemon)
        // so autocomplete Return will work!
        txt.delegate = txt
        
        alertView.addCustomTextfield(txt)

        txt.autocorrectionType = .No
        
        enteredString = txt.text!.lowercaseString
        
        alertView.addButton("Confirm", backgroundColor: UIColor.grayColor()) {
            self.enteredString = txt.text!
            
            //Hardcoded to only check Mewtwo entered in.
            if self.pokemon.contains(self.enteredString.lowercaseString) {
                //Do more stuff like adding marker to map as well as Firebase
                
                self.addPokemonMarkerToFirebase(self.enteredString)
                
                self.justCaptured = self.enteredString.lowercaseString
                alertView.hideView()
            }
            
            if self.validity == false {
                alertView.showWarning("Oops!", subTitle: "Not a valid pokemon.")
            }
        }
        
        alertView.addButton("Cancel", backgroundColor: UIColor.redColor()) {
            alertView.hideView()
        }
        alertView.showInfo("Congratulations!", subTitle: "Which pokemon did you catch?", circleIconImage: alertViewIcon)
        
       
        
    }
    
    // MARK: searching for a pokemon
    // For Angel: When they press on this button, it means they're searching for the pokemon. This method disimsses the keyboard.
    func donePressed(sender: UIButton!) {
        dismissButtons()
        let searchName = ((mySearchTextField?.text)! as String).lowercaseString
        if self.pokemon.contains(searchName) {
            
            self.mapView?.clear()
            
            let query = (ref!.child("\(searchName)")).queryOrderedByKey()
            
            query.observeEventType(.Value, withBlock: { (snapshot) -> Void in
                
                for elem in snapshot.children {
                    let lat = elem.value["latitude"] as! Double
                    let lon = elem.value["longitude"] as! Double
                    let timestamp = elem.value["timestamp"] as! Double
                    self.addMarkerToMap(lat, lon: lon, name: searchName, timestamp: timestamp, dbid: elem.key)
                }
            })
            let currlat = Double((locationManager.location?.coordinate.latitude)!)
            let currlon = Double((locationManager.location?.coordinate.longitude)!)

            let cameraPos = GMSCameraPosition.cameraWithLatitude(currlat, longitude: currlon, zoom: (mapView?.camera.zoom)!)

            mapView!.camera = cameraPos
            mapView!.animateToZoom(7)
            
        } else {
            rerenderMapWithPokemon()
            
        }
        mySearchTextField?.text = ""
        mySearchTextField?.resignFirstResponder()
        
        
    }
    
    // timestamp, pokemon name, facebook ID, upvotes, lat, lon
    func addPokemonMarkerToFirebase(pokemonName: String) {
        let lat = Double((self.locationManager.location?.coordinate.latitude)!)
        let lon = Double((self.locationManager.location?.coordinate.longitude)!)
        let timestamp = NSDate().timeIntervalSince1970


        
        let pokemonNameLowerCase = pokemonName.lowercaseString
        
        // server-side database update
        let uniqueKey = ref!.child("markers").childByAutoId().key
        let newMarkerPost = ["timestamp": timestamp,
                             "latitude": lat,
                             "longitude": lon,
                             "upvotes": "0",
                             "pokemon": pokemonNameLowerCase,
                             "deviceId": getUserId(),
                             "team": getUsersTeam()]
        
        let postChildUpdate = ["/\(pokemonNameLowerCase)/\(uniqueKey)": newMarkerPost,
                               "/markers/\(uniqueKey)": newMarkerPost]
        
        ref!.updateChildValues(postChildUpdate)
        
        // client-side map update
        addMarkerToMap(lat, lon: lon, name: pokemonName, timestamp: timestamp, dbid: uniqueKey)
        rerenderMapWithPokemon()
        
        let cameraPos = GMSCameraPosition.cameraWithLatitude(lat, longitude: lon, zoom: 15)
        mapView!.camera = cameraPos
        mapView!.animateToZoom(18)

        
    }

    func addMarkerToMap(lat: Double, lon: Double, name: String, timestamp: Double, dbid: String) {
        var marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2DMake(lat, lon)
        let icon = UIImage.init(named: name.lowercaseString)
        if icon != nil {
            if name == "pokegym" || name == "pokestop" {
                print("came into here")
                marker.icon = resizeImage(icon!, newHeight: 65.0)
            } else {
                marker.icon = resizeImage(icon!, newHeight: 45.0)
            }
            
            
        } else {
            marker.icon = icon
        }
        
        let dateCaptured = NSDate(timeIntervalSince1970: timestamp)
        let currDate = NSDate()
        
        let timestamp = currDate.offsetFrom(dateCaptured)
        
        marker.title = "\(name)"
        marker.snippet = "\(timestamp), 0 upvotes"
        marker.map = self.mapView
        marker.userData = ExtraMarkerData(id: dbid)
    }
    
    func resizeImage(image: UIImage, newHeight: CGFloat) -> UIImage {
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    func makeSearchPokemonTextField() -> SearchTextField {
        
        let placeholder = NSAttributedString(string: "pokemon name", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        let screenWidth = UIScreen.mainScreen().bounds.width
        
        mySearchTextField = SearchTextField(frame: CGRectMake(10, 30, screenWidth * 15/20, 40))
        mySearchTextField!.theme.fontColor = UIColor.blackColor()
        mySearchTextField!.attributedPlaceholder = placeholder
        
        let item1 = SearchTextFieldItem(title: "Bulbasaur", subtitle: "Type: Grass/Poison", image: UIImage(named: "bulbasaur"))
        let item2 = SearchTextFieldItem(title: "Charmander", subtitle: "Type: Fire", image: UIImage(named: "charmander"))
        let item3 = SearchTextFieldItem(title: "Squirtle", subtitle: "Type: Water", image: UIImage(named: "squirtle"))
        let item4 = SearchTextFieldItem(title: "Caterpie", subtitle: "Type: Bug", image: UIImage(named: "caterpie"))
        let item5 = SearchTextFieldItem(title: "Metapod", subtitle: "Type: Bug", image: UIImage(named: "metapod"))
        let item6 = SearchTextFieldItem(title: "Weedle", subtitle: "Type: Bug", image: UIImage(named: "weedle"))
        let item7 = SearchTextFieldItem(title: "Pidgey", subtitle: "Type: Normal", image: UIImage(named: "pidgey"))
        let item8 = SearchTextFieldItem(title: "Rattata", subtitle: "Type: Normal", image: UIImage(named: "rattata"))
        let item9 = SearchTextFieldItem(title: "Spearow", subtitle: "Type: Flying", image: UIImage(named: "spearow"))
        let item10 = SearchTextFieldItem(title: "Ekans", subtitle: "Type: Poison", image: UIImage(named: "ekans"))
        let item11 = SearchTextFieldItem(title: "Pikachu", subtitle: "Type: Electric", image: UIImage(named: "pikachu"))
        let item12 = SearchTextFieldItem(title: "Sandshrew", subtitle: "Type: Ground", image: UIImage(named: "sandshrew"))
        let item13 = SearchTextFieldItem(title: "Nidoran-F", subtitle: "Type: Poison", image: UIImage(named: "nidoran-f"))
        let item14 = SearchTextFieldItem(title: "Nidoran-M", subtitle: "Type: Poison", image: UIImage(named: "nidoran-m"))
        let item15 = SearchTextFieldItem(title: "Clefairy", subtitle: "Type: Fairy", image: UIImage(named: "clefairy"))
        let item16 = SearchTextFieldItem(title: "Vulpix", subtitle: "Type: Water", image: UIImage(named: "squirtle"))
        //        let item17 = SearchTextFieldItem(title: "Squirtle", subtitle: "Type: Fire", image: UIImage(named: "vulpix"))
        let item18 = SearchTextFieldItem(title: "Jigglypuff", subtitle: "Type: Normal/Fairy", image: UIImage(named: "jigglypuff"))
        let item19 = SearchTextFieldItem(title: "Zubat", subtitle: "Type: Poison/Flying", image: UIImage(named: "zubat"))
        let item20 = SearchTextFieldItem(title: "Oddish", subtitle: "Type: Grass/Poison", image: UIImage(named: "oddish"))
        let item21 = SearchTextFieldItem(title: "Paras", subtitle: "Type: Bug/Grass", image: UIImage(named: "paras"))
        let item22 = SearchTextFieldItem(title: "Venonat", subtitle: "Type: Bug/Poison", image: UIImage(named: "venonat"))
        let item23 = SearchTextFieldItem(title: "Diglett", subtitle: "Type: Ground", image: UIImage(named: "diglett"))
        let item24 = SearchTextFieldItem(title: "Meowth", subtitle: "Type: Normal", image: UIImage(named: "meowth"))
        let item25 = SearchTextFieldItem(title: "Psyduck", subtitle: "Type: Water", image: UIImage(named: "psyduck"))
        let item26 = SearchTextFieldItem(title: "Mankey", subtitle: "Type: Fighting", image: UIImage(named: "mankey"))
        let item27 = SearchTextFieldItem(title: "Growlithe", subtitle: "Type: Fire", image: UIImage(named: "growlithe"))
        let item28 = SearchTextFieldItem(title: "Poliwag", subtitle: "Type: Water", image: UIImage(named: "poliwag"))
        let item29 = SearchTextFieldItem(title: "Abra", subtitle: "Type: Psychic", image: UIImage(named: "abra"))
        let item30 = SearchTextFieldItem(title: "Machop", subtitle: "Type: Fighting", image: UIImage(named: "machop"))
        let item31 = SearchTextFieldItem(title: "Bellsprout", subtitle: "Type: Grass/Poison", image: UIImage(named: "bellsprout"))
        let item32 = SearchTextFieldItem(title: "Tentacool", subtitle: "Type: Water/Poison", image: UIImage(named: "tentacool"))
        let item33 = SearchTextFieldItem(title: "Geodude", subtitle: "Type: Rock/Ground", image: UIImage(named: "geodude"))
        let item34 = SearchTextFieldItem(title: "Ponyta", subtitle: "Type: Fire", image: UIImage(named: "ponyta"))
        let item35 = SearchTextFieldItem(title: "Slowpoke", subtitle: "Type: Water/Psychic", image: UIImage(named: "slowpoke"))
        let item36 = SearchTextFieldItem(title: "Magnemite", subtitle: "Type: Electric/Steel", image: UIImage(named: "magnemite"))
        let item37 = SearchTextFieldItem(title: "Farfetch'd", subtitle: "Type: Normal/Flying", image: UIImage(named: "farfetchd"))
        let item38 = SearchTextFieldItem(title: "Doduo", subtitle: "Type: Normal/Flying", image: UIImage(named: "doduo"))
        let item39 = SearchTextFieldItem(title: "Seel", subtitle: "Type: Water", image: UIImage(named: "seel"))
        let item40 = SearchTextFieldItem(title: "Shellder", subtitle: "Type: Water", image: UIImage(named: "shellder"))
        let item41 = SearchTextFieldItem(title: "Gastly", subtitle: "Type: Ghost/Poison", image: UIImage(named: "gastly"))
        let item42 = SearchTextFieldItem(title: "Onix", subtitle: "Type: Rock/Ground", image: UIImage(named: "onix"))
        let item43 = SearchTextFieldItem(title: "Drowzee", subtitle: "Type: Psychic", image: UIImage(named: "drowzee"))
        let item44 = SearchTextFieldItem(title: "Krabby", subtitle: "Type: Water", image: UIImage(named: "krabby"))
        let item45 = SearchTextFieldItem(title: "Voltorb", subtitle: "Type: Electric", image: UIImage(named: "voltorb"))
        let item46 = SearchTextFieldItem(title: "Exeggcute", subtitle: "Type: Grass/Psychic", image: UIImage(named: "exeggcute"))
        let item47 = SearchTextFieldItem(title: "Cubone", subtitle: "Type: Ground", image: UIImage(named: "cubone"))
        let item48 = SearchTextFieldItem(title: "Hitmonlee", subtitle: "Type: Fighting", image: UIImage(named: "hitmonlee"))
        let item49 = SearchTextFieldItem(title: "Hitmonchan", subtitle: "Type: Fighting", image: UIImage(named: "hitmonchan"))
        let item50 = SearchTextFieldItem(title: "Lickitung", subtitle: "Type: Normal", image: UIImage(named: "lickitung"))
        let item51 = SearchTextFieldItem(title: "Koffing", subtitle: "Type: Poison", image: UIImage(named: "koffing"))
        let item52 = SearchTextFieldItem(title: "Rhyhorn", subtitle: "Type: Ground/Rock", image: UIImage(named: "rhyhorn"))
        let item53 = SearchTextFieldItem(title: "Chansey", subtitle: "Type: Normal", image: UIImage(named: "chansey"))
        let item54 = SearchTextFieldItem(title: "Tangela", subtitle: "Type: Grass", image: UIImage(named: "tangela"))
        let item55 = SearchTextFieldItem(title: "Kangashkan", subtitle: "Type: Normal", image: UIImage(named: "kangaskhan"))
        let item56 = SearchTextFieldItem(title: "Horsea", subtitle: "Type: Water", image: UIImage(named: "horsea"))
        let item57 = SearchTextFieldItem(title: "Goldeen", subtitle: "Type: Water", image: UIImage(named: "goldeen"))
        let item58 = SearchTextFieldItem(title: "Mr.Mime", subtitle: "Type: Psychic/Fairy", image: UIImage(named: "mrmime"))
        let item59 = SearchTextFieldItem(title: "Scyther", subtitle: "Bug/Flying", image: UIImage(named: "scyther"))
        let item60 = SearchTextFieldItem(title: "Jynx", subtitle: "Type: Ice/Psychic", image: UIImage(named: "jynx"))
        let item61 = SearchTextFieldItem(title: "Electabuzz", subtitle: "Type: Electric", image: UIImage(named: "electabuzz"))
        let item62 = SearchTextFieldItem(title: "Magmar", subtitle: "Type: Fire", image: UIImage(named: "magmar"))
        let item63 = SearchTextFieldItem(title: "Pinsir", subtitle: "Type: Bug", image: UIImage(named: "pinsir"))
        let item64 = SearchTextFieldItem(title: "Tauros", subtitle: "Type: Normal", image: UIImage(named: "tauros"))
        let item65 = SearchTextFieldItem(title: "Magikarp", subtitle: "Type: Water", image: UIImage(named: "magikarp"))
        let item66 = SearchTextFieldItem(title: "Lapras", subtitle: "Type: Water/Ice", image: UIImage(named: "lapras"))
        let item67 = SearchTextFieldItem(title: "Ditto", subtitle: "Type: Normal", image: UIImage(named: "ditto"))
        let item68 = SearchTextFieldItem(title: "Eevee", subtitle: "Type: Normal", image: UIImage(named: "eevee"))
        let item69 = SearchTextFieldItem(title: "Porygon", subtitle: "Type: Normal", image: UIImage(named: "porygon"))
        let item70 = SearchTextFieldItem(title: "Omanyte", subtitle: "Type: Rock/Water", image: UIImage(named: "omanyte"))
        let item71 = SearchTextFieldItem(title: "Kabuto", subtitle: "Type: Rock/Water", image: UIImage(named: "kabuto"))
        let item72 = SearchTextFieldItem(title: "Aerodactyl", subtitle: "Type: Rock/Flying", image: UIImage(named: "aerodactyl"))
        let item73 = SearchTextFieldItem(title: "Snorlax", subtitle: "Type: Normal", image: UIImage(named: "snorlax"))
        let item74 = SearchTextFieldItem(title: "Articuno", subtitle: "Type: Ice/Flying", image: UIImage(named: "articuno"))
        let item75 = SearchTextFieldItem(title: "Zapdos", subtitle: "Type: Electric/Flying", image: UIImage(named: "zapdos"))
        let item76 = SearchTextFieldItem(title: "Moltres", subtitle: "Type: Fire/Flying", image: UIImage(named: "moltres"))
        let item77 = SearchTextFieldItem(title: "Dratini", subtitle: "Type: Dragon", image: UIImage(named: "dratini"))
        let item78 = SearchTextFieldItem(title: "Kakuna", subtitle: "Type: Bug", image: UIImage(named: "kakuna"))
        //        let item79 = SearchTextFieldItem(title: "Beedrill", subtitle: "Type: Bug", image: UIImage(named: "beedrill"))
        let item80 = SearchTextFieldItem(title: "Pidgeotto", subtitle: "Type: Normal/Flying", image: UIImage(named: "pidgeotto"))
        let item81 = SearchTextFieldItem(title: "Pidgeot", subtitle: "Type: Normal/Flying", image: UIImage(named: "pidgeot"))
        let item82 = SearchTextFieldItem(title: "Raticate", subtitle: "Type: Normal", image: UIImage(named: "raticate"))
        let item83 = SearchTextFieldItem(title: "Fearow", subtitle: "Type: Flying", image: UIImage(named: "fearow"))
        let item84 = SearchTextFieldItem(title: "Arbok", subtitle: "Type: Normal/Flying", image: UIImage(named: "arbok"))
        let item85 = SearchTextFieldItem(title: "Sandslash", subtitle: "Type: Ground", image: UIImage(named: "sandslash"))
        let item86 = SearchTextFieldItem(title: "Nidorina", subtitle: "Type: Poison", image: UIImage(named: "nidorina"))
        let item87 = SearchTextFieldItem(title: "Nidoqueen", subtitle: "Type: Poison", image: UIImage(named: "nidoqueen"))
        let item88 = SearchTextFieldItem(title: "Nidorino", subtitle: "Type: Poison", image: UIImage(named: "nidorino"))
        let item89 = SearchTextFieldItem(title: "Nidoking", subtitle: "Type: Poison", image: UIImage(named: "nidoking"))
        let item90 = SearchTextFieldItem(title: "Clefable", subtitle: "Type: Fairy", image: UIImage(named: "clefable"))
        let item91 = SearchTextFieldItem(title: "Ninetales", subtitle: "Type: Fire", image: UIImage(named: "ninetales"))
        let item92 = SearchTextFieldItem(title: "Wigglytuff", subtitle: "Type: Normal/Fairy", image: UIImage(named: "wigglytuff"))
        let item93 = SearchTextFieldItem(title: "Golbat", subtitle: "Type: Poison/Flying", image: UIImage(named: "golbat"))
        let item94 = SearchTextFieldItem(title: "Gloom", subtitle: "Type: Grass/Poison", image: UIImage(named: "gloom"))
        let item95 = SearchTextFieldItem(title: "Vileplume", subtitle: "Type: Grass/Poison", image: UIImage(named: "vileplume"))
        let item96 = SearchTextFieldItem(title: "Parasect", subtitle: "Type: Bug/Grass", image: UIImage(named: "parasect"))
        let item97 = SearchTextFieldItem(title: "Venomoth", subtitle: "Type: Bug/Poison", image: UIImage(named: "venomoth"))
        let item98 = SearchTextFieldItem(title: "Dugtrio", subtitle: "Type: Ground", image: UIImage(named: "dugtrio"))
        let item99 = SearchTextFieldItem(title: "Persian", subtitle: "Type: Normal", image: UIImage(named: "persian"))
        let item100 = SearchTextFieldItem(title: "Golduck", subtitle: "Type: Water", image: UIImage(named: "golduck"))
        let item101 = SearchTextFieldItem(title: "Primeape", subtitle: "Type: Fighting", image: UIImage(named: "primeape"))
        let item102 = SearchTextFieldItem(title: "Arcanine", subtitle: "Type: Fire", image: UIImage(named: "arcanine"))
        let item103 = SearchTextFieldItem(title: "Polywhirl", subtitle: "Type: Water", image: UIImage(named: "polywhirl"))
        let item104 = SearchTextFieldItem(title: "Polywrath", subtitle: "Type: Water", image: UIImage(named: "polywrath"))
        let item105 = SearchTextFieldItem(title: "Kadabra", subtitle: "Type: Psychic", image: UIImage(named: "kadabra"))
        let item106 = SearchTextFieldItem(title: "Alakazam", subtitle: "Type: Psychic", image: UIImage(named: "alakazam"))
        let item107 = SearchTextFieldItem(title: "Machoke", subtitle: "Type: Fighting", image: UIImage(named: "machoke"))
        let item108 = SearchTextFieldItem(title: "Machamp", subtitle: "Type: Fighting", image: UIImage(named: "machamp"))
        let item109 = SearchTextFieldItem(title: "Weepinbell", subtitle: "Type: Grass/Poison", image: UIImage(named: "weepinbell"))
        let item110 = SearchTextFieldItem(title: "Beedrill", subtitle: "Type: Bug", image: UIImage(named: "beedrill"))
        let item111 = SearchTextFieldItem(title: "Victreebel", subtitle: "Type: Grass/Poison", image: UIImage(named: "victreebel"))
        let item112 = SearchTextFieldItem(title: "Tentacruel", subtitle: "Type: Water/Poison", image: UIImage(named: "tentacruel"))
        let item113 = SearchTextFieldItem(title: "Graveler", subtitle: "Type: Rock/Ground", image: UIImage(named: "graveler"))
        let item114 = SearchTextFieldItem(title: "Golem", subtitle: "Type: Rock/Ground", image: UIImage(named: "golem"))
        let item115 = SearchTextFieldItem(title: "Rapidash", subtitle: "Type: Fire", image: UIImage(named: "rapidash"))
        let item116 = SearchTextFieldItem(title: "Slowbro", subtitle: "Type: Water/Psychic", image: UIImage(named: "slowbro"))
        let item117 = SearchTextFieldItem(title: "Magneton", subtitle: "Type: Electric/Steel", image: UIImage(named: "magneton"))
        let item118 = SearchTextFieldItem(title: "Dodrio", subtitle: "Type: Normal/Flying", image: UIImage(named: "dodrio"))
        let item119 = SearchTextFieldItem(title: "Dewgong", subtitle: "Type: Water/Ice", image: UIImage(named: "dewgong"))
        let item120 = SearchTextFieldItem(title: "Muk", subtitle: "Type: Poison", image: UIImage(named: "muk"))
        let item121 = SearchTextFieldItem(title: "Cloyster", subtitle: "Type: Water/Ice", image: UIImage(named: "cloyster"))
        let item122 = SearchTextFieldItem(title: "Haunter", subtitle: "Type: Ghost/Poison", image: UIImage(named: "haunter"))
        let item123 = SearchTextFieldItem(title: "Gengar", subtitle: "Type: Ghost/Poison", image: UIImage(named: "gengar"))
        let item124 = SearchTextFieldItem(title: "Hypno", subtitle: "Type: Psychic", image: UIImage(named: "hypno"))
        let item125 = SearchTextFieldItem(title: "Kingler", subtitle: "Type: Water", image: UIImage(named: "kingler"))
        let item126 = SearchTextFieldItem(title: "Electrode", subtitle: "Type: Electric", image: UIImage(named: "electrode"))
        let item127 = SearchTextFieldItem(title: "Exeggutor", subtitle: "Type: Grass/Psychic", image: UIImage(named: "exeggutor"))
        let item128 = SearchTextFieldItem(title: "Marowak", subtitle: "Type: Ground", image: UIImage(named: "marowak"))
        let item129 = SearchTextFieldItem(title: "Weezing", subtitle: "Type: Poison", image: UIImage(named: "weezing"))
        let item130 = SearchTextFieldItem(title: "Rhydon", subtitle: "Type: Ground/Rock", image: UIImage(named: "rhydon"))
        let item131 = SearchTextFieldItem(title: "Seadra", subtitle: "Type: Water", image: UIImage(named: "seadra"))
        let item132 = SearchTextFieldItem(title: "Seaking", subtitle: "Type: Water", image: UIImage(named: "seaking"))
        let item133 = SearchTextFieldItem(title: "Starmie", subtitle: "Type: Water", image: UIImage(named: "starmie"))
        let item134 = SearchTextFieldItem(title: "Gyarados", subtitle: "Type: Water", image: UIImage(named: "gyarados"))
        let item135 = SearchTextFieldItem(title: "Vaporeon", subtitle: "Type: Water", image: UIImage(named: "vaporeon"))
        let item136 = SearchTextFieldItem(title: "Jolteon", subtitle: "Type: Electric", image: UIImage(named: "jolteon"))
        let item137 = SearchTextFieldItem(title: "Flareon", subtitle: "Type: Fire", image: UIImage(named: "flareon"))
        let item138 = SearchTextFieldItem(title: "Omastar", subtitle: "Type: Rock/Water", image: UIImage(named: "omastar"))
        let item139 = SearchTextFieldItem(title: "Kabutops", subtitle: "Type: Rock/Water", image: UIImage(named: "kabutops"))
        let item140 = SearchTextFieldItem(title: "Dragonair", subtitle: "Type: Dragon", image: UIImage(named: "dragonair"))
        let item141 = SearchTextFieldItem(title: "Mewtwo", subtitle: "Type: Psychic", image: UIImage(named: "mewtwo"))
        let item142 = SearchTextFieldItem(title: "Blastoise", subtitle: "Type: Water", image: UIImage(named: "blastoise"))
        let item143 = SearchTextFieldItem(title: "Wartortle", subtitle: "Type: Water", image: UIImage(named: "wartortle"))
        let item144 = SearchTextFieldItem(title: "Venusaur", subtitle: "Type: Grass/Poison", image: UIImage(named: "venusaur"))
        let item145 = SearchTextFieldItem(title: "Ivysaur", subtitle: "Type: Grass/Poison", image: UIImage(named: "ivysaur"))
        let item146 = SearchTextFieldItem(title: "Charmeleon", subtitle: "Type: Fire", image: UIImage(named: "charmeleon"))
        let item147 = SearchTextFieldItem(title: "Charizard", subtitle: "Type: Fire", image: UIImage(named: "charizard"))
        let item148 = SearchTextFieldItem(title: "Raichu", subtitle: "Type: Electric", image: UIImage(named: "raichu"))
        let item149 = SearchTextFieldItem(title: "PokeStop", subtitle: "Type: Stop", image: UIImage(named: "pokestop"))
        let item150 = SearchTextFieldItem(title: "PokeGym", subtitle: "Type: Gym", image: UIImage(named: "pokegym"))
        
        mySearchTextField!.filterItems([item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12, item13, item14, item15, item16, item18, item19, item20, item21, item22, item23, item24, item25, item26, item27, item28,
            item29, item30, item31, item32, item33, item34, item35, item36, item37, item38, item39, item40, item41, item42, item43, item44, item45, item46, item47, item48, item49, item50, item51, item52, item53, item54, item55, item56, item57, item58, item59, item60, item61, item62, item63, item64, item65, item66, item67, item68, item69, item70, item71, item72, item73, item74, item75, item76, item77, item78, item80, item81, item82, item83, item84, item85, item86, item87, item88, item89, item90, item91, item92, item93, item94, item95, item96, item97, item98, item99, item100, item101, item102, item103, item104, item105, item106, item107, item108, item109, item110, item111, item112, item113, item114, item115, item116, item117, item118, item119, item120, item121, item122, item123, item124, item125, item126, item127, item128, item129, item130, item131, item132, item133, item134, item135, item136, item137, item138, item139, item140, item141, item142, item143, item144, item145, item146, item147, item148, item149, item150])
        
        mySearchTextField!.itemSelectionHandler = {item in
            //Chosen Pokemon will be self.mySearchTextField!
            self.mySearchTextField!.text = item.title
        }
        mySearchTextField!.maxNumberOfResults = 7
        mySearchTextField!.theme.cellHeight = 50
        mySearchTextField!.backgroundColor = UIColor.whiteColor()
        mySearchTextField!.clearButtonMode = .WhileEditing
        mySearchTextField!.borderStyle = UITextBorderStyle.RoundedRect
        
        
        return mySearchTextField!
    }
    
    
    func getUsersTeam() -> String {
        return chosenTeamName
    }
    
    func getUserId() -> String {
        let returnedString = UIDevice.currentDevice().identifierForVendor!.UUIDString
        return returnedString
    }
 
    
    let myFirstButton = UIButton()
    let mySecondButton = UIButton()
    let myThirdButton = UIButton()
    
    var buttonsOn = false
    
    var lastPressed = "none"
    func mapView(mapView: GMSMapView!, didCloseInfoWindowOfMarker marker: GMSMarker!) {
        if self.lastMarkerTapped == nil {
            dismissButtons()
        } else if self.lastMarkerTapped!.title == lastPressed && changed == false {
                dismissButtons()
        } else if marker.title == self.lastMarkerTapped!.title && lastPressedPosition.longitude != self.lastMarkerTapped?.position.longitude && lastPressedPosition.latitude != self.lastMarkerTapped?.position.latitude {
            dismissButtons()
        } else if lastPressed == "none" {
            dismissButtons()
        } else if mapView.selectedMarker?.position.longitude == lastPressedPosition.longitude && mapView.selectedMarker?.position.latitude == lastPressedPosition.latitude && marker.title == "pokegym" {
            dismissButtons()
        } else if lastPressedPosition.longitude == marker.position.longitude && lastPressedPosition.latitude == marker.position.latitude{
            dismissButtons()
        }
        
    }

    
    
    
    
    var changed = false
    var lastPressedPosition = CLLocationCoordinate2DMake(127.1, 127.1)
//    
    //marker pressed
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        print("my changed is:", changed)
        //re-render upvotes
        let dbid = (marker.userData as! ExtraMarkerData).getdbID()
        print("hello1")
        ref!.child("markers/\(dbid)").observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
            let latestUpvotes = snapshot.value!["upvotes"]!
            let timestamp = (marker.snippet?.componentsSeparatedByString(","))![0]
            marker.snippet = timestamp + ", " + "\(latestUpvotes!)" + " upvotes"
        })
        print("hello2")

        print(marker)
        self.lastMarkerTapped = marker
        
        
        print("last marker pressed had name of", self.lastMarkerTapped!.title)
            print("lastpressed was: ", lastPressed)
        print("buttons are now:", buttonsOn)
        if buttonsOn == true && lastPressed == self.lastMarkerTapped!.title && self.lastMarkerTapped?.position.latitude == lastPressedPosition.latitude && self.lastMarkerTapped?.position.longitude == lastPressedPosition.longitude {
            changed = false
            
            dismissButtons()
            print("i should be dismissed right now")
            self.lastMarkerTapped = nil
            
        } else {
            lastPressed = self.lastMarkerTapped!.title!
            lastPressedPosition = (self.lastMarkerTapped?.position)!
            buttonsOn = true
            changed = true
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        
        //Upvote button
        myFirstButton.setBackgroundImage(UIImage(named:"upvote.png"), forState: .Normal)
        myFirstButton.layer.masksToBounds = false
        myFirstButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).CGColor
        myFirstButton.layer.shadowOpacity = 1.0
        myFirstButton.layer.shadowRadius = 0
        myFirstButton.layer.shadowOffset = CGSizeMake(0, 2.0)
        myFirstButton.frame = CGRectMake(screenWidth * 1/4, screenHeight * 4/5, 80, 80)
        myFirstButton.addTarget(self, action: "upvote", forControlEvents: .TouchUpInside)
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.myFirstButton.alpha = 0.0
                self.myFirstButton.alpha = 1.0
        }, completion: nil)
        self.view.addSubview(myFirstButton)
        
        //Downvote button
        mySecondButton.setBackgroundImage(UIImage(named:"downvote.png"), forState: .Normal)
        mySecondButton.layer.masksToBounds = false
        mySecondButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).CGColor
        mySecondButton.layer.shadowOpacity = 1.0
        mySecondButton.layer.shadowRadius = 0
        mySecondButton.layer.shadowOffset = CGSizeMake(0, 2.0)
        mySecondButton.frame = CGRectMake(screenWidth * 2/4, screenHeight * 4/5, 80, 80)
        mySecondButton.addTarget(self, action: "downvote", forControlEvents: .TouchUpInside)
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            
                self.mySecondButton.alpha = 0.0
                self.mySecondButton.alpha = 1.0
            
        }, completion: nil)
        self.view.addSubview(mySecondButton)
        }
        
        if self.lastMarkerTapped != nil && self.lastMarkerTapped!.title != "pokegym" {
            myThirdButton.removeFromSuperview()
        }
        
        if self.lastMarkerTapped != nil && self.lastMarkerTapped!.title == "pokegym" {
            //Help button
            print("came in gym")
            print(chosenTeamName)
            let screenHeight = UIScreen.mainScreen().bounds.height
            let screenWidth = UIScreen.mainScreen().bounds.width
            let defaults = NSUserDefaults.standardUserDefaults()
            let name = defaults.stringForKey("chosenTeam")
            
            if name == "blue" {
                myThirdButton.setBackgroundImage(UIImage(named:"helpBlue.png"), forState: .Normal)
            } else if name == "yellow" {
                myThirdButton.setBackgroundImage(UIImage(named:"helpYellow.png"), forState: .Normal)
            } else if name == "red" {
                myThirdButton.setBackgroundImage(UIImage(named:"helpRed.png"), forState: .Normal)
            }
            myThirdButton.layer.masksToBounds = false
            myThirdButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).CGColor
            myThirdButton.layer.shadowOpacity = 1.0
            myThirdButton.layer.shadowRadius = 0
            myThirdButton.layer.shadowOffset = CGSizeMake(0, 2.0)
            myThirdButton.frame = CGRectMake(screenWidth * 3/8, screenHeight * 7/10, 80, 80)
            myThirdButton.addTarget(self, action: "helpButton", forControlEvents: .TouchUpInside)
            
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.myThirdButton.alpha = 0.0
                self.myThirdButton.alpha = 1.0
                }, completion: nil)
            self.view.addSubview(myThirdButton)
        }
    
        return false
    }
    
    
    
    func dismissButtons() {
        buttonsOn = false
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            
            self.myFirstButton.alpha = 0.0
            
            }, completion: nil)
    
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            
            self.mySecondButton.alpha = 0.0
            
            }, completion: nil)
        
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            
            self.myThirdButton.alpha = 0.0
            
            }, completion: nil)
        if mapView?.selectedMarker == nil {
//            removeButtons()
                   NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.2), target: self, selector: "removeButtons", userInfo: nil, repeats: false)
        }
        
 
        
    }

    func removeButtons() {
        
        myFirstButton.removeFromSuperview()
        mySecondButton.removeFromSuperview()
        myThirdButton.removeFromSuperview()
    }
    
    func upvote() {
        print("upvoted here")
        let extraMarkerData = self.lastMarkerTapped?.userData as! ExtraMarkerData
        let dbid = extraMarkerData.getdbID()
        
        let currMarkerRef = ref?.child("markers/\(dbid)")
        currMarkerRef?.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            var marker = currentData.value as? [String: AnyObject]
            //var upvotes: Int = Int(marker!["upvotes"] as! String)!
            var upvotes:Int = Int(marker!["upvotes"] as! String)!
            upvotes += 1
            print(upvotes)
            marker!["upvotes"] = String(upvotes)
            currentData.value = marker
            return FIRTransactionResult.successWithValue(currentData)
        })
        print("hola")
        print(dbid)
        print("senor")
//
//        ref?.child("markers/\(dbid)").observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
//            var upvoteCount = snapshot.value!["upvotes"] as! Int
//            upvoteCount += 1
//            // wrap this in transaction later
//            // update the markers list
//            self.ref!.child("markers").child(dbid).setValue(["upvotes": upvoteCount])
        
//        })

        dismissButtons()
    }
    
    func downvote() {
        print("downvoted here")
        dismissButtons()
    }
    
    func helpButton() {
        print("pressed help")
        dismissButtons()
        mapView?.selectedMarker = nil
    }
    
 


    
}





extension NSDate {
    
    func offsetFrom(date:NSDate) -> String {
        
        let dayHourMinuteSecond: NSCalendarUnit = [.Day, .Hour, .Minute, .Second]
        let difference = NSCalendar.currentCalendar().components(dayHourMinuteSecond, fromDate: date, toDate: self, options: [])
        
//        let seconds = "\(difference.second)s"
        let minutes = "\(difference.minute)m"
        let hours = "\(difference.hour)h" + " " + minutes
        let days = "\(difference.day)d" + " " + hours
        
        if difference.day    > 0 { return days }
        if difference.hour   > 0 { return hours }
        if difference.minute > 0 { return minutes }
//        if difference.second > 0 { return seconds }
        
//        print(days)
        return ""
    }
    
}

