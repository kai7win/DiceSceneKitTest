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
        cameraNode.position = SCNVector3(x: 0, y: -1.5, z: 12)
        scene.rootNode.addChildNode(cameraNode)
        
        for i in 0...1 {
            var row: [SCNNode] = []
            for j in -1...1 {
                let diceNode = createDiceNode()
                ///这边Y轴加 负号 是因为在SceneKit的踩笛卡尔坐标 Y是往上 跟屏幕坐标相反
                diceNode.position = SCNVector3(j, -i + 1, 0)
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
        material1.diffuse.contents = UIImage(named: "redDice1")
        
        let material2 = SCNMaterial()
        material2.diffuse.contents = UIImage(named: "redDice2")
        
        let material3 = SCNMaterial()
        material3.diffuse.contents = UIImage(named: "redDice3")
        
        let material4 = SCNMaterial()
        material4.diffuse.contents = UIImage(named: "redDice4")
        
        let material5 = SCNMaterial()
        material5.diffuse.contents = UIImage(named: "redDice5")
        
        let material6 = SCNMaterial()
        material6.diffuse.contents = UIImage(named: "redDice6")
        
        diceGeometry.materials = [material1, material2, material6, material5, material3, material4]
        diceNode.geometry = diceGeometry
        return diceNode
    }
    
    @objc func rollDice() {
        for (rowIndex, diceRow) in diceNodes.enumerated() {
            for (colIndex, diceNode) in diceRow.enumerated() {
                // 旋转事件的Array
                var rotationActions: [SCNAction] = []
                
                // 添加5次乱数不同角度的旋转事件 存进Array
                for _ in 1...5 {
                    let rotationAction = SCNAction.rotateBy(
                        x: CGFloat.random(in: 0...CGFloat.pi * 2),
                        y: CGFloat.random(in: 0...CGFloat.pi * 2),
                        z: CGFloat.random(in: 0...CGFloat.pi * 2),
                        duration: 0.5
                    )
                    rotationActions.append(rotationAction)
                }
                
                // 计算每个骰子的结果Index取出完成骰子需对应的点数
                let resultIndex = rowIndex * diceRow.count + colIndex
                let diceFace = self.preSetRollResults[resultIndex % preSetRollResults.count]
                
                
                let completionAction = SCNAction.run { _ in
                    diceNode.eulerAngles = self.rotationForDiceFace(diceFace)
                }
                
                // 添加完成的旋转事件
                rotationActions.append(completionAction)
                
                // 执行旋转的动作
                let sequenceAction = SCNAction.sequence(rotationActions)
                diceNode.runAction(sequenceAction)
            }
        }
    }
    
    ///SCNVector3(0, 0, 0) 1
    ///SCNVector3(0, -CGFloat.pi / 2, 0) 2
    ///SCNVector3(CGFloat.pi / 2, 0, 0) 3
    ///SCNVector3(-CGFloat.pi / 2, 0, 0) 4
    ///SCNVector3(0, CGFloat.pi / 2, 0) 5
    ///SCNVector3(CGFloat.pi, 0, 0) 6
    
    
    func rotationForDiceFace(_ face: Int) -> SCNVector3 {
        switch face {
        case 1: return SCNVector3(0, 0, 0)
        case 2: return SCNVector3(0, -CGFloat.pi / 2, 0)
        case 3: return SCNVector3(CGFloat.pi / 2, 0, 0)
        case 4: return SCNVector3(-CGFloat.pi / 2, 0, 0)
        case 5: return SCNVector3(0, CGFloat.pi / 2, 0)
        case 6: return SCNVector3(CGFloat.pi, 0, 0)
        default: return SCNVector3(CGFloat.pi, 0, 0)
        }
    }
}


