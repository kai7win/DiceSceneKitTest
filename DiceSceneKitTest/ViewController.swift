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
        
        
        let boundingBoxNode = createBoundingBox()
        scene.rootNode.addChildNode(boundingBoxNode)
        
        
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
                
                // 记录原始位置
                let originalPosition = diceNode.position
                
                // 创建物理体身体
                let dicePhysicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: diceNode.geometry!, options: nil))
                
                // 调整物理体的质量和弹性
                dicePhysicsBody.mass = 0.1 // 根据需要调整这个值
                dicePhysicsBody.restitution = 0.01 // 降低反弹能量
                dicePhysicsBody.friction = 0.7 // 增加摩擦力
                
                diceNode.physicsBody = dicePhysicsBody
                
                // 添加力和扭矩
                let forceMagnitude: Float = 0.2 // 根据需要调整这个值
                
                let force = SCNVector3(x: Float.random(in: -forceMagnitude...forceMagnitude),
                                       y: Float.random(in: -forceMagnitude...forceMagnitude),
                                       z: Float.random(in: -forceMagnitude...forceMagnitude))
                diceNode.physicsBody?.applyForce(force, asImpulse: true)
                
                let torque = SCNVector4(x: Float.random(in: -1...1), y: Float.random(in: -1...1), z: Float.random(in: -1...1), w: Float.random(in: -1...1))
                diceNode.physicsBody?.applyTorque(torque, asImpulse: false)
                
                
                // 计算每个骰子的结果Index取出完成骰子需对应的点数
                let resultIndex = rowIndex * diceRow.count + colIndex
                let diceFace = self.preSetRollResults[resultIndex % preSetRollResults.count]
                
                // 骰子聚集的位置
                let gatheringPoint = SCNVector3(0, 0.5, 0)
                
                // 创建骰子聚集的动作
                let moveToGatheringPointAction = SCNAction.move(to: gatheringPoint, duration: 0.2)
                
                //                // 稍微等待一下
                //                let waitAction = SCNAction.wait(duration: 0.2)
                
                var rotationActions: [SCNAction] = []
                // 添加3次乱数不同角度的旋转事件 存进Array
                for _ in 1...3 {
                    let rotationAction = SCNAction.rotateBy(
                        x: CGFloat.random(in: 0...CGFloat.pi ),
                        y: CGFloat.random(in: 0...CGFloat.pi ),
                        z: CGFloat.random(in: 0...CGFloat.pi ),
                        duration: 0.5
                    )
                    rotationActions.append(rotationAction)
                }
                
                let completionAction = SCNAction.run { _ in
                    diceNode.eulerAngles = self.rotationForDiceFace(diceFace)
                }
                
                let makeStaticAction = SCNAction.run { _ in
                    diceNode.physicsBody?.type = .static
                }
                
                let endPositionAction = SCNAction.move(to: originalPosition, duration: 0.3)
                
                var allActions: [SCNAction] = []
                
                /// 移动到一起、碰撞、旋转、完成、静止、回到原本位置
                allActions.append(contentsOf: [moveToGatheringPointAction])
                allActions.append(contentsOf: rotationActions)
                allActions.append(contentsOf: [completionAction,makeStaticAction, endPositionAction])
                
                // 执行全部的动作
                let sequenceAction = SCNAction.sequence(allActions)
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
    
    func createBoundingBox() -> SCNNode {
        let boxGeometry = SCNBox(width: 3, height: 3, length: 5, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        
        // 使几何体看起来是透明的
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor.clear
        //        transparentMaterial.diffuse.contents = UIColor.yellow
        boxGeometry.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial]
        
        // 添加物理体範圍
        let physicsShape = SCNPhysicsShape(geometry: boxGeometry, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        boxNode.physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        
        
        return boxNode
    }
    
    
}


