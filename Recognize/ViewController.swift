//
//  ViewController.swift
//  Recognize
//
//  Created by Flavio Forenza on 03/07/2020.
//  Copyright © 2020 Flavio Forenza. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate{
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    //all 3D render
    var davidScene:SCNScene!
    
    let labelObject = UILabel()
    
    var labelExist = [String]()
    
    var objectRecognize = [String]()
    
    var augmentedON = false
    
    //for Augmented Reality everywhere
    var buttonIsPressed = false
    var buttonPlayIsPressed = false
        
    let buttonAR = UIButton(type: .custom)
    let buttonPlay = UIButton(type: .custom)
    let buttonStop = UIButton(type: .custom)
    
    var animationLabel = false
    
    let configuration = ARWorldTrackingConfiguration()
    
    //dipslay size
    let w = UIScreen.main.bounds.width
    let h = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        davidScene = SCNScene(named: "art.scnassets/MainScene.scn")
        addButtonAR()
        addButtonPlay()
        addButtonStop()
    }
    
    @objc func buttonAction(button: UIButton){
        buttonPlay.isEnabled = false
        
        //if buttonAR hasn't been pressed
        if !buttonIsPressed{
            buttonIsPressed = true
            
            let newScene = SCNScene()
            
            for childNode in self.davidScene.rootNode.childNodes as [SCNNode]{
                newScene.rootNode.addChildNode(childNode.clone())
            }
            
            //view of AR object
            let node = newScene.rootNode.childNode(withName: "AR", recursively: true)
            
            //add all label description
            newScene.rootNode.enumerateChildNodes{(child, _ ) in
                //get all .sks
                let existScene = getSKScene()
                for elem in existScene.spriteKitScene{
                    //if label exist
                    if elem.contains(child.name! + " Scena"){
                        var nodeLabel = SCNNode()
                        //check if there is a corrispondence to a second node (a empty node)
                        let corr = correspondence()
                        var secondName:String = ""
                        //(key: firstNode, value: secondNode)
                        for (key, _) in corr.correspondence{
                            if key == child.name{
                                secondName = corr.correspondence[key]!
                            }
                        }
                        if secondName != ""{
                            var secondNode = SCNNode()
                            for singleNode in newScene.rootNode.childNodes{
                                if singleNode.name == secondName{
                                    secondNode = singleNode
                                }
                            }
                            nodeLabel = self.addLabelDescription(currentNode: secondNode, ObjName: child.name!, coordinate: getCordLabel(name: child.name!))
                        }else{
                            nodeLabel = self.addLabelDescription(currentNode: child, ObjName: child.name!, coordinate: getCordLabel(name: child.name!))
                        }
                        nodeLabel.name = "Descrizione " + child.name!
                        child.parent?.addChildNode(nodeLabel)
                    }
                }
            }
            
            sceneView.scene = newScene
            
            sceneView.pointOfView?.pivot = SCNMatrix4MakeTranslation(-node!.position.x, -node!.position.y, -node!.position.z)
        }else{
            
            //remove all
            sceneView.scene.rootNode.enumerateChildNodes{(child, _ ) in
                child.removeFromParentNode()
            }
            
            buttonIsPressed = false
            buttonPlay.isEnabled = true
        }
        
    }
    
    func addButtonAR(){
        buttonAR.frame = CGRect(x: w-60, y: h-110, width: 50, height: 50)
        buttonAR.layer.borderWidth = 2
        buttonAR.layer.cornerRadius = 25
        buttonAR.backgroundColor = UIColor.lightText
        let typeIcon = UIImage.SymbolConfiguration(weight: .bold)
        let sizeIcon = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let combineConfig = typeIcon.applying(sizeIcon)
        let icon = UIImage(systemName: "arkit", withConfiguration: combineConfig)
        buttonAR.setImage(icon, for: .normal)
        buttonAR.setTitleColor(UIColor.black, for: .normal)
        buttonAR.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(buttonAR)
    }
    
    @objc func buttonPlayAction(button: UIButton){
        buttonPlayIsPressed = true
        buttonPlay.isHidden = true
        buttonStop.isHidden = false
        buttonAR.isEnabled = false
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    func addButtonPlay(){
        buttonPlay.frame = CGRect(x: w/2-25, y: h-110, width: 50, height: 50)
        buttonPlay.layer.borderWidth = 2
        buttonPlay.layer.cornerRadius = 25
        buttonPlay.backgroundColor = UIColor.lightText
        let typeIcon = UIImage.SymbolConfiguration(weight: .bold)
        let sizeIcon = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let combineConfig = typeIcon.applying(sizeIcon)
        let icon = UIImage(systemName: "play.fill", withConfiguration: combineConfig)
        buttonPlay.setImage(icon, for: .normal)
        buttonPlay.setTitleColor(UIColor.black, for: .normal)
        buttonPlay.addTarget(self, action: #selector(buttonPlayAction), for: .touchUpInside)
        self.view.addSubview(buttonPlay)
    }
    
    @objc func buttonStopAction(){
        if augmentedON{
            sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
            let arrayOfNode = nodeArr
            for arrElem in arrayOfNode{
                self.davidScene.rootNode.addChildNode(arrElem.clone())
            }
            
            if !labelExist.isEmpty{
                labelExist = []
            }
            
            augmentedON = false
        }
        buttonStop.isHidden = true
        buttonPlay.isHidden = false
        buttonAR.isEnabled = true
        buttonPlayIsPressed = false
    }
    
    func addButtonStop(){
        buttonStop.frame = CGRect(x: w/2-25, y: h-110, width: 50, height: 50)
        buttonStop.layer.borderWidth = 2
        buttonStop.layer.cornerRadius = 25
        buttonStop.backgroundColor = UIColor.lightText
        let typeIcon = UIImage.SymbolConfiguration(weight: .bold)
        let sizeIcon = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let combineConfig = typeIcon.applying(sizeIcon)
        let icon = UIImage(systemName: "stop.fill", withConfiguration: combineConfig)
        buttonStop.setImage(icon, for: .normal)
        buttonStop.setTitleColor(UIColor.black, for: .normal)
        buttonStop.addTarget(self, action: #selector(buttonStopAction), for: .touchUpInside)
        buttonStop.isHidden = true
        self.view.addSubview(buttonStop)
    }
    
    func setupScene(){
        sceneView.debugOptions = [.showFeaturePoints]
        //gestisce il tutto
        sceneView.delegate = self
        sceneView.showsStatistics = true
        //improvements ambient light
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        //fps
        sceneView.preferredFramesPerSecond = 60
//        sceneView.allowsCameraControl = true
        sceneView.antialiasingMode = .multisampling4X
        
        if let camera = sceneView.pointOfView?.camera {
            //enable HDR mode
            camera.wantsHDR = true
            //automatically set the exposure
            camera.wantsExposureAdaptation = true
            //to light up the scene
            camera.exposureOffset = 1
            camera.minimumExposure = 1
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //single object 3D to detect
        if let storedObjects = ARReferenceObject.referenceObjects(inGroupNamed:"AR Resources Object", bundle: nil){
            configuration.detectionObjects = storedObjects
        }
        
        //multiple group-image to detect
        let groupImage = groupName()
        
        for group in groupImage.groupName{
            if let storedImage = ARReferenceImage.referenceImages(inGroupNamed: group, bundle: nil){
                //image --> ARReferenceImage
                for image in storedImage{
                    configuration.detectionImages.insert(image)
                }
            }
        }
        
        sceneView.session.run(configuration, options: [.resetTracking])
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //false - true
        if buttonPlayIsPressed{
            DispatchQueue.main.async {
                self.scan2DImage(anchor: anchor, node: node)
                self.scan3DObject(anchor: anchor, node: node)
            }
        }
    }
    
    //update info StatisticalLabel --> Last Object detect
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if buttonPlayIsPressed{
            DispatchQueue.main.async {
                let name = getNameAnchor(anchorID: anchor.name!)
                if self.augmentedON{
                    self.createStatiscalLabel(object: name)
                }
            }
        }
    }
    
    func scan2DImage(anchor: ARAnchor, node: SCNNode){
        //Image
        if let imageAnchor = anchor as? ARImageAnchor {
            
            let name = getNameAnchor(anchorID: anchor.name!)
            
            //add only label description
            //if there are 3D model in the scene
            if augmentedON{
                sceneView.scene.rootNode.enumerateChildNodes{(child, _ ) in
                    //child.name --> name in MainScene
                    if child.name == name{
                        //add only label Description
                        if !labelExist.contains(name){
                            var nodeLabel = SCNNode()
                            let corr = correspondence()
                            let secondName = corr.correspondence[name]
                            if secondName != nil{
                                let secondNode = getNode(name: corr.correspondence[name]!)
                                nodeLabel = self.addLabelDescription(currentNode: secondNode, ObjName: name, coordinate: getCordLabel(name: name))
                            }else{
                                nodeLabel = self.addLabelDescription(currentNode: child, ObjName: name, coordinate: getCordLabel(name: name))
                            }
                            nodeLabel.name = "Descrizione " + name
                            child.parent?.addChildNode(nodeLabel)
                            labelExist.append(name)
                        }
                    }
                }
            }else{
                let numb = Int(anchor.name!)
                                
                switch numb! {
                case 4:
                    addObjToScene(node: node, name: name, yUp: false, coordinate: getCordLabel(name: name), include: false, secondObject: "Quadro Muse Pos")
                case 8:
                    addObjToScene(node: node, name: name, yUp: false, coordinate: getCordLabel(name: name), include: true, secondObject: "")
                default:
                    print("No match found")
                }
            }
        }
    }
    
    func scan3DObject(anchor: ARAnchor, node: SCNNode){
        //3D object
        if let objectAnchor = anchor as? ARObjectAnchor{
                        
            let name = getNameAnchor(anchorID: anchor.name!)
            
            //add label description if object isn't rootNode
            if augmentedON{
                sceneView.scene.rootNode.enumerateChildNodes{(child, _ ) in
                    if child.name == name{
                        //add only label Description
                        if !labelExist.contains(name){
                            let nodeLabel = self.addLabelDescription(currentNode: child, ObjName: name, coordinate: getCordLabel(name: name))
                            nodeLabel.name = "Descrizione \(name)"
                            child.parent?.addChildNode(nodeLabel)
                            labelExist.append(name)
                        }
                    }
                }
            }else{
                let numb = Int(anchor.name!)
                
                switch numb! {
                case 1...3:
                    addObjToScene(node: node, name: name, yUp: true, coordinate: getCordLabel(name: name), include: true, secondObject: "")
                default:
                    fatalError("Not match found")
                }
            }
            
        }
    }
    
    func addObjToScene(node: SCNNode, name: String, yUp: Bool, coordinate: [Float], include: Bool, secondObject: String){
        for childNode in self.davidScene.rootNode.childNodes as [SCNNode]{
            AddNode(childNode.clone())
            
            if(childNode.name == name){
                if include{
                    node.addChildNode(childNode)
                }else{
                    //reference to second node
                    let secondNode = davidScene.rootNode.childNode(withName: secondObject, recursively: true)
                    childNode.position = secondNode!.position
                    childNode.eulerAngles = secondNode!.eulerAngles
                }
                
                //create labelDescription
                let nodeLabel = self.addLabelDescription(currentNode: childNode, ObjName: name, coordinate: coordinate)
                nodeLabel.name = "Descrizione \(name)"
                node.addChildNode(nodeLabel)
                
                //coordinate object
                let x = childNode.position.x
                let y = childNode.position.y
                let z = childNode.position.z
                
                let xRad = childNode.eulerAngles.x
                let yRad = childNode.eulerAngles.y
                let zRad = childNode.eulerAngles.z
                
                //move pivot in same position of object
                node.pivot = SCNMatrix4MakeTranslation(x,y,z)
                
                if !yUp{
                    node.pivot = SCNMatrix4Rotate(node.pivot, xRad, 1, 0, 0)
                    node.pivot = SCNMatrix4Rotate(node.pivot, yRad, 0, 0, 1)
                    node.pivot = SCNMatrix4Rotate(node.pivot, zRad, 0, 1, 0)
                }else{
                    node.pivot = SCNMatrix4Rotate(node.pivot, xRad, 1, 0, 0)
                    node.pivot = SCNMatrix4Rotate(node.pivot, yRad, 0, 1, 0)
                    node.pivot = SCNMatrix4Rotate(node.pivot, zRad, 0, 0, 1)
                }
                
                self.sceneView.scene.rootNode.addChildNode(node)
                
                //return back from original position and eulerangles
                //useful for view objects that have a reference when AR button is pressed
                if !include{
                    let lastNode = getNode(name: name)
                    childNode.position = lastNode.position
                    childNode.eulerAngles = lastNode.eulerAngles
                }
                augmentedON = true
            }else{
                if childNode.name != "AR" || childNode.name != "Quadro Muse Pos"{
                    node.addChildNode(childNode)
                }
            }
        }
    }
    
    func createStatiscalLabel(object: String) -> UILabel{
        
        self.labelObject.alpha = 1
        labelObject.text = "Object: \(object)"
        labelObject.textAlignment = .center
        labelObject.textColor = UIColor.blue
        labelObject.frame = CGRect(x: w/2 - 125, y: 50, width: 250, height: 50)
        labelObject.textColor = UIColor.white
        labelObject.layer.cornerRadius = 25
        labelObject.font = UIFont.boldSystemFont(ofSize: 18)
        labelObject.backgroundColor = UIColor.systemGray4
        //for the corner effects
        labelObject.layer.masksToBounds = true
        sceneView.addSubview(labelObject)
        
        UIView.animate(
            withDuration: 5,
            delay: 0,
            options: [],
            animations: {self.labelObject.alpha = 0},
            completion: nil
        )
        
        return labelObject
    }
    
    func addLabelDescription(currentNode: SCNNode, ObjName: String, coordinate: [Float]) -> SCNNode{
        
        //dimensione label
        let plane = SCNPlane(width: CGFloat(0.18), height: CGFloat(0.18))
        plane.cornerRadius = plane.width/8
        
        //get sks
        let spriteKitScene = SKScene(fileNamed: ObjName + " Scena")
        spriteKitScene?.backgroundColor = .darkGray
        
        //get information about title and description of object
        let (title, description) = getDescription(name: ObjName)
        
        if let labelTitle = spriteKitScene?.childNode(withName: "Title") as? SKLabelNode{
            labelTitle.text = title
            labelTitle.fontSize = 50
            labelTitle.verticalAlignmentMode = .top
            labelTitle.fontColor = .black
            labelTitle.fontName = "Arial"
        }
        
        if let labelDescription = spriteKitScene?.childNode(withName: "Description") as? SKLabelNode{
            labelDescription.text = description
            labelDescription.fontSize = 34
            labelDescription.verticalAlignmentMode = .center
            labelDescription.fontColor = .black
            labelDescription.fontName = "Arial"
        }
        
        plane.firstMaterial?.diffuse.contents = spriteKitScene
        plane.firstMaterial?.isDoubleSided = true
        //make translate of entire plane to show all element in correct position
        plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0 ,1, 0)
        
        //move the plane relative to the childNode
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(currentNode.position.x + coordinate[0],
                                            currentNode.position.y + coordinate[1],
                                            currentNode.position.z)
        
        planeNode.eulerAngles.x = 0
        if currentNode.eulerAngles.y < 0{
            planeNode.eulerAngles.y = -currentNode.eulerAngles.y
        }else{
            planeNode.eulerAngles.y = currentNode.eulerAngles.y
        }
        planeNode.eulerAngles.z = 0
        
        return planeNode
    }
}

