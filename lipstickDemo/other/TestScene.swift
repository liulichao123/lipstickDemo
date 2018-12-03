//
//  TestScene.swift
//  lipstickDemo
//
//  Created by 天明 on 2018/11/30.
//  Copyright © 2018 天明. All rights reserved.
//

import Foundation
import SpriteKit

/// 一些学习测试
class TestScene: SKScene {
    var label : SKLabelNode!
    var topNode: SKShapeNode!
    var topNodeBody: SKPhysicsBody!
    var shapeNodeBody: SKPhysicsBody!
    var shapeNode : SKShapeNode!
    var sanjiaoTexture: SKTexture!
    var sanjiaoNode: SKSpriteNode!
    
    var landCategory: UInt32 = 0x00000001
    var birdCategory: UInt32 = 0x00000001
    var birdCategory1: UInt32 = 0x10000000
    
    
    override init(size: CGSize) {
        super.init(size: size)
        common()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        common()
    }
    
    
    
    func addLabel() {
        label = SKLabelNode(text: "哈哈哈哈哈哈")
        label.position = CGPoint(x: 100, y: 100)
        label.fontSize = 20
        label.fontColor = UIColor.red
        self.addChild(label)
        label.physicsBody = SKPhysicsBody(rectangleOf: label.frame.size, center: CGPoint(x: 0, y: 0))
        label.physicsBody?.affectedByGravity = false
    }
    
    func addTopNode() {
        topNode = SKShapeNode(rect: CGRect(x: 100, y: 500, width: 100, height: 100))
        topNode.name = "topNode"
        topNode.fillColor = UIColor.red
        topNode.strokeColor = UIColor.blue
        addChild(topNode)
    }
    
    func addShapeNode() {
        shapeNode = SKShapeNode()
        shapeNode.name = "shapeNode"
        let path = CGMutablePath()
        let x: CGFloat = 100+40
        path.addLines(between: [CGPoint(x: x, y: 0), CGPoint(x: x+100, y: 0),
                                CGPoint(x: x+100, y: 100),
                                CGPoint(x: x+100-20, y: 100), CGPoint(x: x+100-20, y: 20), CGPoint(x: x, y: 20),
                                CGPoint(x: x, y: 0)
                                ])
        path.closeSubpath()
        shapeNode.path = path
        shapeNode.fillColor = UIColor.yellow
        shapeNode.strokeColor = UIColor.purple
        addChild(shapeNode)
        
        shapeNodeBody = SKPhysicsBody(polygonFrom: path)
        shapeNodeBody.isDynamic = false//忽略应用于它的所有力和脉冲
        shapeNodeBody.affectedByGravity = false
        shapeNodeBody.categoryBitMask = landCategory
        shapeNodeBody.collisionBitMask = birdCategory
        shapeNodeBody.contactTestBitMask = birdCategory
        
        shapeNode.physicsBody = shapeNodeBody
        
    }
    
    func addSanjiao() {
        sanjiaoTexture = SKTexture(imageNamed: "sanjiao")
        sanjiaoNode = SKSpriteNode(texture: sanjiaoTexture)
        sanjiaoNode.name = "sanjiaoNode"
        sanjiaoNode.size = CGSize(width: 100, height: 100)
        sanjiaoNode.position = CGPoint(x: 120, y: 300)
        addChild(sanjiaoNode)
    }
    
//    override func didMove(to view: SKView) {
//
//    }
    
    func common() {
//        addTopNode()
        addSanjiao()
        addShapeNode()
        self.physicsWorld.contactDelegate = self
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        topNodeBody = SKPhysicsBody(polygonFrom: topNode.path!)
//        topNodeBody.affectedByGravity = true
//        topNodeBody.categoryBitMask = birdCategory
//        topNode.physicsBody = topNodeBody
     
        let body = SKPhysicsBody(texture: sanjiaoTexture, size: sanjiaoNode.size)
        body.categoryBitMask = birdCategory
//        body.affectedByGravity = false
        sanjiaoNode.physicsBody = body
    }
}

extension TestScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
        if let AName = contact.bodyB.node?.name, let BName = contact.bodyA.node?.name {
            print(AName, BName)
            contact.bodyB.node?.physicsBody = nil
            contact.bodyA.node?.physicsBody = nil
//            contact.bodyA.node?.physicsBody?.velocity = CGVector.init(dx: 0, dy: 0)
//            contact.bodyA.node?.physicsBody?.angularVelocity = 0
           
        }
       
        
//        print(contact.bodyA, contact.bodyB)
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
//        print(contact.bodyB.node?.frame, contact.bodyA.node?.frame)
//        contact.bodyB.node?.physicsBody = nil
//        contact.bodyA.node?.physicsBody = nil
    }
    
}


/*
 碰撞检测设置步骤：
 1.添加场景代理SKPhysicsContactDelegate
 2.设置self.physicsWorld.contactDelegate = self
 3.设置接触抛事件ground.physicsBody?.contactTestBitMask = horseCategory
 
 spritekit的碰撞检测，是通过设定这三个值来实现的
 
 ground.physicsBody?.categoryBitMask = landCategory
 ground.physicsBody?.contactTestBitMask = birdCategory
 ground.physicsBody?.collisionBitMask = birdCategory
 文档中的解释分别是：
 1.一个标记，定义了这个物体所属分类
 2.一个标记，定义了哪种物体接触到该物体，该物体会收到通知（谁撞我我会收到通知）
 3.一个标记，定义了哪种物体会碰撞到自己
 第二种是用来抛出接触消息的，第三种是用来检测碰撞的。碰撞检测，默认所有物体之间互相可碰撞。接触消息，默认所有物体接触都不产生消息，这样是为了保证效率。当你对某种接触感兴趣时，单独设置contactCategory，监听这类碰撞消息。
 **/
