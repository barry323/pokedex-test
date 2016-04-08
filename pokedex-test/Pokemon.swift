//
//  Pokemon.swift
//  pokedex-test
//
//  Created by Barry Chan on 7/4/2016.
//  Copyright © 2016 equiltech. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {

    private var _name:String!
    private var _pokedexId: Int!
    private var _desc:String!
    private var _type:String!
    private var _defense:String!
    private var _height:String!
    private var _weight:String!
    private var _baseAtt:String!
    private var _nextEvo:String!
    private var _nextEvoId:String!
    private var _nextEvoLvl:String!
    private var _pokemonURL:String!
    
    var name:String {
        get {
            return self._name
        }
    }
    
    var pokedexId:Int {
        get {
            return self._pokedexId
        }
    }
    
    var desc:String {
        get {
            if self._desc == nil {
                return ""
            }
            return self._desc
        }
    }
    
    var type:String {
        get {
            if self._type == nil {
                return ""
            }
            return self._type
        }
    }
    
    var defense:String {
        get {
            if self._defense == nil {
                return ""
            }
            return self._defense
        }
    }
    
    var height:String {
        get {
            if self._height == nil {
                return ""
            }
            return self._height
        }
    }
    
    var weight:String {
        get {
            if self._weight == nil {
                return ""
            }
            return self._weight
        }
    }
    
    var baseAtt:String {
        get {
            if self._baseAtt == nil {
                return ""
            }
            return self._baseAtt
        }
    }
    
    var nextEvo:String {
        get {
            if self._nextEvo == nil {
                return ""
            }
            return self._nextEvo
        }
    }
    
    var nextEvoId:String {
        get {
            if self._nextEvoId == nil {
                return ""
            }
            return self._nextEvoId
        }
    }
    
    var nextEvoLvl:String {
        get {
            if self._nextEvoLvl == nil {
                return ""
            }
            return self._nextEvoLvl
        }
    }
    
    var pokemonURL:String {
        get {
            if self._pokemonURL == nil {
                return ""
            }
            return self._pokemonURL
        }
    }
    
    init(name: String, pokedexId: Int){
        self._name = name
        self._pokedexId = pokedexId
        
        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self._pokedexId)/"
    }
    
    func downloadPokemonDetails(completed:DownloadComplete){
        
        let url = NSURL(string: self._pokemonURL)!
        Alamofire.request(.GET, url).responseJSON { response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }
                
                if let height = dict["height"] as? String {
                    self._height = height
                }
                
                if let attack = dict["attack"] as? String {
                    self._baseAtt = attack
                }
                
                if let defense = dict["defense"] as? String {
                    self._defense = defense
                }
                
                if let types = dict["types"] as? [Dictionary<String, String>] where types.count > 0 {
                    
                    if let type_name = types[0]["name"] {
                        self._type = type_name
                    }
                    
                    if types.count > 1 {
                        
                        for x in 1..<types.count {
                            let type_name = types[x]["name"]
                            self._type! += "\(type_name?.capitalizedString)"
                        }
                    }
                } else  {
                    self._type = ""
                }
                
                if let descArr = dict["descriptions"] as? [Dictionary<String, String>] where descArr.count > 0 {
                
                    if let resource_uri = descArr[0]["resource_uri"] {
                        let url = NSURL(string: "\(URL_BASE)\(resource_uri)")!
                        Alamofire.request(.GET, url).responseJSON{ response in
                        
                            if let descResult = result.value as? Dictionary<String, String> {
                                if let desc = descResult["description"] {
                                    self._desc = desc
                                }
                            }
                            
                            completed()
                        }
                    }
                } else {
                    self._desc = ""
                }
                
                if let evo_dict = dict["evolutions"] as? [Dictionary<String, AnyObject>] where evo_dict.count > 0 {
                    
                    if let to = evo_dict[0]["to"] as? String {
                    
                        if to.rangeOfString("mega") == nil {
                            
                            if let resource_uri = evo_dict[0]["resource_uri"] as? String {
                                
                                let newStr = resource_uri.stringByReplacingOccurrencesOfString("/api/v1/pokemon/", withString: "")
                                
                                let num = newStr.stringByReplacingOccurrencesOfString(newStr, withString: "/")
                                
                                
                                self._nextEvo = newStr
                                self._nextEvoId = num
                                
                                if let level = evo_dict[0]["level"] as? Int {
                                    self._nextEvoLvl = "\(level)"
                                } else {
                                    self._nextEvoLvl = ""
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
}