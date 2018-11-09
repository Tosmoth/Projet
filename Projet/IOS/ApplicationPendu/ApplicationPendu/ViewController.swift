//
//  ViewController.swift
//  ApplicationPendu
//
//  Created by etudiant on 05/11/2018.
//  Copyright © 2018 etudiant. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit
import CoreMotion


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate  {
    @IBOutlet weak var myImg: UIImageView!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var et_letter: UITextView!
    @IBOutlet weak var btn_send: UIButton!
    @IBOutlet weak var jouer: UIButton!
    @IBOutlet weak var btn_pos: UIButton!
    @IBOutlet weak var txt: UITextView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var seekbar: UISlider!
    
    //Pendu
    var jeu: Hangman = Hangman()
    var secondes = 0
    var imageNumber = 0
    var imageName = "first"
    var start = false
    
    //Music
    var player:AVAudioPlayer = AVAudioPlayer()
    
    @IBAction func play(_ sender: Any) {
        player.play()
    }
    
    @IBAction func pause(_ sender: Any) {
        player.pause()
    }
    
    @IBAction func replay(_ sender: Any) {
        player.currentTime = 0
    }
    
    //Map
    @IBOutlet weak var mapView: MKMapView!
    
    let manager = CLLocationManager()
    
    func locationManager( _ manager : CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations[0]
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        
        print(location.altitude)
        print(location.speed)
        
        self.mapView.showsUserLocation = true
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Maps
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        //Music
        do{
            let audioPath = Bundle.main.path(forResource: "song", ofType: "mp3")
            try player = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath : audioPath!) as URL)
        }
        catch{
            
        }
        
        seekbar.maximumValue = Float (player.duration)
        
 
    
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    
    class Hangman
    {
        var motSecret: String
        var mot: String
        var mot_format: String
        var lettre: String
        var essais: Int
        var victoire: Bool
        var phrases : NSArray!
        
        
        init()
        {
            
            self.mot = ""
            self.mot_format = ""
            self.essais = 6
            self.victoire = false
            self.lettre = "a"
            self.motSecret = ""
            
            
            let path = Bundle.main.path(forResource:"pendu_liste", ofType: "txt")
            phrases = NSArray.init(contentsOfFile: path!)
        }
        
        func initialiserJeu()
        {
            self.mot = ""
            self.essais = 6
            self.victoire = false
            self.motSecret = getRandomPhrase()
            initialiserMot()
        }
        
        func initialiserMot()
        {
            
            var str_tmp = ""
            var pos = 0
            
            for char in motSecret
            {
                if let index = motSecret.index(of: char)
                {
                    pos = motSecret.distance(from: motSecret.startIndex, to: index)
                    print("\(char) existe ->  position \(pos)")
                    
                    
                    if (char == " ")
                    {
                        str_tmp.append(" ")
                    }
                    else
                    {
                        str_tmp.append("-")
                    }
                    
                }
            }
            
            print("Format -> \(str_tmp) du mot secret \(motSecret)")
            mot = str_tmp
        }
        
        
        func verifierLettre(letter: String) -> Int
        {
            print("Comparaison de la lettre...")
            
            
            var index: Int = 0;
            
            for char in motSecret
            {
                if char == Character(letter)
                {
                    if let idx = motSecret.index(of: char)
                    {
                        let pos = motSecret.distance(from: motSecret.startIndex, to: idx)
                        print("\(char) existe ->  position \(pos)")
                        
                        return pos
                    }
                    
                    
                }
                
                index += 1
            }
            
            print("> False")
            return -1
        }
        
        func remplacerLettre(index: Int, letter: String)
        {
            var index_str = 0
            
            for char in motSecret
            {
                if char == Character(letter)
                {
                    if let idx = motSecret.index(of: char)
                    {
                        let pos = motSecret.distance(from: motSecret.startIndex, to: idx)
                        print("\(char) existe ->  position \(pos)")
                        let _index = mot.index(mot.startIndex, offsetBy: index_str)
                        mot.replaceSubrange(_index..._index, with: letter)
                    }
                }
                
                index_str += 1
            }
            
            print(mot)
            
            formaterMot()
        }
        
        func formaterMot()
        {
            
            var str_tmp = ""
            var pos = 0
            
            for char in mot
            {
                if let index = mot.index(of: char)
                {
                    pos = mot.distance(from: mot.startIndex, to: index)
                    print("\(char) existe ->  position \(pos)")
                    
                    if (pos < (mot.count - 1))
                    {
                        str_tmp.append(char)
                    }
                    else
                    {
                        str_tmp.append(char)
                    }
                }
            }
            
            print("Format -> \(str_tmp)")
            mot_format = str_tmp
        }
        
        
        func getRandomPhrase() -> String!
        {
            let index = Int(arc4random_uniform(UInt32(phrases.count)))
            return phrases.object(at: index) as! String
        }
    }

    @IBAction func ChangeAudioTime(_ sender: Any) {
        
        player.stop()
        player.currentTime = TimeInterval(seekbar.value)
        player.prepareToPlay()
        player.play()
        
        
    }
    
    func updateSlider(){
        seekbar.value = Float(player.currentTime)
        NSLog("HI")
        
    }
    
    @IBAction func takephoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated : true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            myImg.contentMode = .scaleToFill
            myImg.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func Position(_ sender: Any) {
        
    }
    
    //Gyroscope
    var motionManager = CMMotionManager()
    override func viewDidAppear(_ animated: Bool) {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!){ (data, error) in
            if let myData = data{
                print(myData)
            }
            
        }
    }
    
}
    



