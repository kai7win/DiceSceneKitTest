//
//  ViewController.swift
//  DiceSceneKitTest
//
//  Created by Kai Chi Tsao on 2023/7/12.
//

import UIKit
import SceneKit

class ViewController: UIViewController {

    var diceNodes: [[SCNNode]] = []
    var preSetRollResults: [Int] = [1, 2, 3, 4, 5, 6]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scnView = SCNView(frame: self.view.frame)
        self.view.addSubview(scnView)
        
        let scene = SCNScene()
        scnView.scene = scene
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        scene.rootNode.addChildNode(cameraNode)
        
        for i in 0...1 {
            var row: [SCNNode] = []
            for j in -1...1 {
                let diceNode = createDiceNode()
                diceNode.position = SCNVector3(j, i, 0)
                scene.rootNode.addChildNode(diceNode)
                row.append(diceNode)
            }
            diceNodes.append(row)
        }
        
        let rollButton = UIButton(frame: CGRect(x: 20, y: view.bounds.height - 70, width: view.bounds.width - 40, height: 50))
        rollButton.setTitle("博一博", for: .normal)
        rollButton.backgroundColor = .systemBlue
        rollButton.addTarget(self, action: #selector(rollDice), for: .touchUpInside)
        view.addSubview(rollButton)
    }
    
    func createDiceNode() -> SCNNode {
        let diceNode = SCNNode()
        let diceGeometry = SCNBox(width: 0.7, height: 0.7, length: 0.7, chamferRadius: 0.15)
        
        let material1 = SCNMaterial()
        material1.diffuse.contents = UIImage(named: "dice1")
        
        let material2 = SCNMaterial()
        material2.diffuse.contents = UIImage(named: "dice2")
        
        let material3 = SCNMaterial()
        material3.diffuse.contents = UIImage(named: "dice3")
        
        let material4 = SCNMaterial()
        material4.diffuse.contents = UIImage(named: "dice4")
        
        let material5 = SCNMaterial()
        material5.diffuse.contents = UIImage(named: "dice5")
        
        let material6 = SCNMaterial()
        material6.diffuse.contents = UIImage(named: "dice6")
        
        diceGeometry.materials = [material1, material2, material3, material4, material5, material6]
        diceNode.geometry = diceGeometry
        return diceNode
    }
    
    @objc func rollDice() {
        for (rowIndex, diceRow) in diceNodes.enumerated() {
            for (colIndex, diceNode) in diceRow.enumerated() {
                // Create an array to store multiple rotation actions
                var rotationActions: [SCNAction] = []
                
                // Add multiple rotation actions to the array
                for _ in 1...5 {
                    let rotationAction = SCNAction.rotateBy(
                        x: CGFloat.random(in: 0...CGFloat.pi * 2),
                        y: CGFloat.random(in: 0...CGFloat.pi * 2),
                        z: CGFloat.random(in: 0...CGFloat.pi * 2),
                        duration: 0.2
                    )
                    rotationActions.append(rotationAction)
                }

                // Calculate the index in the preset roll results array
                let resultIndex = rowIndex * diceRow.count + colIndex
                let diceFace = self.preSetRollResults[resultIndex % preSetRollResults.count]
                let completionAction = SCNAction.run { _ in
                    diceNode.eulerAngles = self.rotationForDiceFace(diceFace)
                }
                
                // Append the completion action to the array
                rotationActions.append(completionAction)
                
                let sequenceAction = SCNAction.sequence(rotationActions)
                diceNode.runAction(sequenceAction)
            }
        }
    }

    
    func rotationForDiceFace(_ face: Int) -> SCNVector3 {
        switch face {
        case 1: return SCNVector3(0, 0, 0)
        case 2: return SCNVector3(0, -CGFloat.pi / 2, 0)
        case 3: return SCNVector3(-CGFloat.pi / 2, 0, 0)
        case 4: return SCNVector3(CGFloat.pi / 2, 0, 0)
        case 5: return SCNVector3(0, CGFloat.pi / 2, 0)
        case 6: return SCNVector3(CGFloat.pi, 0, 0)
        default: return SCNVector3(0, 0, 0)
        }
    }
}


