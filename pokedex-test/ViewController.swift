//
//  ViewController.swift
//  pokedex-test
//
//  Created by Barry Chan on 7/4/2016.
//  Copyright © 2016 equiltech. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collection: UICollectionView!
    
    var pokemon = [Pokemon]()
    var filteredPokemon = [Pokemon]()
    var musicPlayer:AVAudioPlayer!
    var inSearchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBar.delegate = self
        collection.delegate = self
        collection.dataSource = self
        
        self.searchBar.returnKeyType = UIReturnKeyType.Done
        self.initAudio()
        self.parsePokemonCSV()
    }
    
    func initAudio(){
        let path = NSBundle.mainBundle().pathForResource("music", ofType: "mp3")!
        
        do {
            self.musicPlayer = try AVAudioPlayer(contentsOfURL: NSURL(string: path)!)
            self.musicPlayer.prepareToPlay()
            self.musicPlayer.numberOfLoops = -1
            self.musicPlayer.play()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    func parsePokemonCSV(){
        let path = NSBundle.mainBundle().pathForResource("pokemon", ofType: "csv")!
        
        do {
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
        
            for row in rows {
                let pokeId = Int(row["id"]!)!
                let name = row["identifier"]!
                let poke = Pokemon(name: name, pokedexId: pokeId)
                pokemon.append(poke)
            }
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.inSearchMode {
            return self.filteredPokemon.count
        } else {
            return self.pokemon.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let poke:Pokemon!
        
        if self.inSearchMode {
            poke = self.filteredPokemon[indexPath.row]
        } else {
            poke = self.pokemon[indexPath.row]
        }
        
        performSegueWithIdentifier("PokemonDetailVC", sender: poke)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PokeCell", forIndexPath: indexPath) as? PokeCell {
            
            let poke:Pokemon
            
            if self.inSearchMode {
                poke = self.filteredPokemon[indexPath.row]
            } else {
                poke = self.pokemon[indexPath.row]
            }
            
            cell.configureCell(poke)
            return cell
            
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(105, 105)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            self.inSearchMode = false
            self.view.endEditing(true)
            self.collection.reloadData()
        } else {
            self.inSearchMode = true
        
            let lower = searchBar.text!.lowercaseString
            self.filteredPokemon = self.pokemon.filter({$0.name.containsString(lower) != nil })
            self.collection.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PokemonDetailVC" {
            if let detailsVC = segue.destinationViewController as? PokemonDetailVC {
                if let poke = sender as? Pokemon {
                    detailsVC.pokemon = poke
                }
            }
        }
    }
    
    @IBAction func musicBtnPressed(sender: UIButton!) {
        
        if self.musicPlayer.playing {
            self.musicPlayer.stop()
            sender.alpha = 0.2
        } else {
            self.musicPlayer.play()
            sender.alpha = 1.0
        }
    }
}

