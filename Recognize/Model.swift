//
//  Model.swift
//  Recognize
//
//  Created by Flavio Forenza on 04/07/2020.
//  Copyright © 2020 Flavio Forenza. All rights reserved.
//

import Foundation
import ARKit

var nodeArr: [SCNNode] = []

struct correspondence{
    var correspondence = [String:String]()
    init(){
        correspondence["Quadro Muse"] = "Quadro Muse Pos"
    }
}

class AddNode{
    init(_ newNode: SCNNode) {
        nodeArr.append(newNode)
    }
}

func getNode(name:String) -> SCNNode{
    var node = SCNNode()
    for elem in nodeArr{
        if elem.name == name{
            node = elem
        }
    }
    return node.clone()
}

struct groupName{
    var groupName:[String] = []
    init(){
        groupName.append("AR Resources Quadro")
        groupName.append("AR Resources Spade")
        groupName.append("AR Resources Piatti")
    }
}

func getNameAnchor(anchorID: String)->(String){
    var name:String = ""
    
    let numb = Int(anchorID)
    switch numb! {
    case 1...3:
        name = "David Michelangelo"
    case 4:
        name = "Quadro Muse"
    case 8:
        name = "Spada Dx"
    case 9:
        name = "Piatto Centrale"
    case 10:
        name = "Piatto Sx"
    case 11:
        name = "Piatto Dx"
    default:
        fatalError("No object")
    }
    return (name)
}

func getDescription(name: String) -> (String,String){
    let title:String
    let description:String
    switch name {
    case "David Michelangelo":
        title = "David Michelangelo"
        description = """
        Il David è una scultura
        realizzata in marmo
        (altezza 520 cm incluso il
        basamento di 108 cm) da
        Michelangelo Buonarroti,
        databile tra il 1501 e
        l'inizio del 1504
        e conservata nella
        Galleria dell'Accademia
        a Firenze.
        """
    case "Spada Dx":
        title = "Spada Dx"
        description = """
        Questa è la spada di
        Excalibur di Re Artù. La
        sua storia appartiene
        principalmente alla leggenda
        e alla letteratura degli
        inizi del secolo VI, anche
        se si discute se Artù, o un
        personaggio simile nel quale
        si sarebbe basata la
        leggenda, esistette
        realmente.
        """
    case "Quadro Muse":
        title = "Quadro Muse"
        description = """
        Le Muse sono divinità della religione
        greca. Erano le figlie di Zeus e di
        Mnemosine (la "Memoria") e la loro
        guida era Apollo. L'importanza delle
        muse nella religione greca era elevata:
        esse infatti rappresentavano l'ideale
        supremo dell'Arte.
        """
    default:
        title = "Not found"
        description = "Not found"
    }
    
    return (title, description)
}

struct getSKScene{
    var spriteKitScene:[String] = []
    init(){
        spriteKitScene.append("Spada Dx Scena")
        spriteKitScene.append("Quadro Muse Scena")
        spriteKitScene.append("David Michelangelo Scena")
    }
}

struct coordinateLabel{
    var coord = [String:[Float]]()
    init(){
        coord["David Michelangelo"] = [0.15, 0.45]
        coord["Spada Dx"] = [0.1, 0]
        coord["Quadro Muse"] = [0.1, -0.35]
    }
}

func getCordLabel(name: String) -> [Float]{
    let posLbl = coordinateLabel()
    var xy: [Float] = []
    for (key, value) in posLbl.coord{
        if key == name{
            xy = value
        }
    }
    return xy
}


