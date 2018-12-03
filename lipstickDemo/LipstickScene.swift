//
//  LipstickScene.swift
//  lipstickDemo
//
//  Created by 天明 on 2018/12/3.
//  Copyright © 2018 天明. All rights reserved.
//

import Foundation
import SpriteKit

/// 插口红技术原型Scene
class LipstickScene: SKScene {
    
    struct Mask {
        static let landCategory: UInt32 = 0x00000001
        static let birdCategory: UInt32 = 0x00000001
    }
    
    var circleTexture: SKTexture!
    var _circleNode: SKSpriteNode!
    var circleNode: SKSpriteNode!
    var circleBody: SKPhysicsBody!
    var circelAction: SKAction!
    
    var sanjiaoTexture: SKTexture!
    var sanjiaoNode: SKSpriteNode!
    var sanjiaoAction: SKAction!
    
    var sanjiaoNodes: [SKNode] = []
    var sanjiaoNodeSet: Set<SKNode> = []
    override init(size: CGSize) {
        super.init(size: size)
        common()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        common()
    }
    
    func common() {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        // 通过文理对象创建node，该方式是像素化的，碰撞时检测边缘像素，更精确
        circleTexture = SKTexture(imageNamed: "circle")
        circleNode = SKSpriteNode(texture: circleTexture)
        circleNode.name = "circleNode"
        circleNode.size = CGSize(width: 200, height: 200)
        circleNode.position = CGPoint(x: self.frame.width/2, y: self.frame.midY+200)
        addChild(circleNode)
        
        //创建物理体积，circleOfRadius(半径是circleNode.size/4而不是circleNode.size/2,这样做是因为检测碰撞时能检测到三角形的精确碰撞)
        circleBody = SKPhysicsBody(circleOfRadius: 50)
        circleBody.isDynamic = false//忽略应用于它的所有力和脉冲
        circleBody.affectedByGravity = false
        circleBody.categoryBitMask = Mask.landCategory //所属类别
        circleBody.collisionBitMask = Mask.birdCategory// 能响应碰撞的类别
        circleBody.contactTestBitMask = Mask.birdCategory//能够
        circleNode.physicsBody = circleBody
        
        //circleBody.applyAngularImpulse(CGFloat.pi)
        //添加动画
        let action1 = SKAction.rotate(byAngle: CGFloat.pi, duration: 4)
        let action2 = SKAction.rotate(byAngle: -CGFloat.pi*2, duration: 6)
        let sequence = SKAction.sequence([action1, action2])
        circelAction = SKAction.repeatForever(sequence)
        circleNode.run(circelAction)

        //创建发射的三角形文理，作为模板，重复利用
        sanjiaoTexture = SKTexture(imageNamed: "sanjiao")
        createSanjiao()
    }
    
    //创建发射的三角形,利用之前的文理模板
    func createSanjiao() {
        let sanjiaoNode = SKSpriteNode(texture: sanjiaoTexture)
        sanjiaoNode.name = "sanjiaoNode"
        sanjiaoNode.size = CGSize(width: 50, height: 100)
        sanjiaoNode.position = CGPoint(x: self.frame.width/2, y: 100)
        
        let sanjiaoBody = SKPhysicsBody(texture: sanjiaoTexture, size: sanjiaoNode.size)
        sanjiaoBody.categoryBitMask = Mask.birdCategory
        sanjiaoBody.collisionBitMask = Mask.birdCategory
        sanjiaoBody.contactTestBitMask = Mask.birdCategory
        sanjiaoBody.affectedByGravity = false
        sanjiaoNode.physicsBody = sanjiaoBody
        
        addChild(sanjiaoNode)
        self.sanjiaoNode = sanjiaoNode
    }
    
    /// 发射三角形
    func doShot() {
        sanjiaoNode.physicsBody?.applyForce(CGVector(dx: 0, dy: 7000))
    }
    
    /// 测试
    func temp() {
        let topNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 100, height: 100))
        topNode.name = "topNode"
        topNode.fillColor = UIColor.red
        topNode.strokeColor = UIColor.blue
        topNode.position = CGPoint(x: 0, y: -(circleNode.size.height/2+100))
        circleNode.addChild(topNode)
    }
    
    var canTouch = true
    /// 点击屏幕发射
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canTouch {
            canTouch = false
            doShot()
        }
    }
   
}



extension LipstickScene: SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        print("\n-------------------didBegin------------")
        guard let nodeA = contact.bodyA.node, let nodeAName = nodeA.name, let nodeB = contact.bodyB.node, let nodeBName = nodeB.name else {
             print("未知碰撞")
            return
        }
        func insert() {
            // circleNode.speed = 0
            //先让三角形停止
            sanjiaoNode.speed = 0
            //以后不在受碰撞影响
            sanjiaoNode.physicsBody?.isDynamic = false
            
            //根据碰撞点坐标，计算出sanjiaoNode添加到circleNode上后的坐标，同时需要设置角度
            let point = CGPoint.init(x: contact.contactPoint.x, y: contact.contactPoint.y-50)
            let circelContactPoint = self.convert(point, to: circleNode)
           
            sanjiaoNode.position = circelContactPoint
            sanjiaoNode.zRotation = -circleNode.zRotation//这里注意是负的，因为因为碰撞点比circleNode点相比，是少了zRotation的角度
            //必须先移除，再添加
            sanjiaoNode.removeFromParent()
            circleNode.addChild(sanjiaoNode)
            sanjiaoNodeSet.insert(sanjiaoNode)
            
            createSanjiao()
        }
        
        func failed() {
            sanjiaoNode.physicsBody = nil
            sanjiaoNode.removeFromParent()
            
            createSanjiao()
        }
        
        if nodeA == sanjiaoNode {
            if nodeB == circleNode {
                print("插入")
                insert()
            } else if sanjiaoNodeSet.contains(nodeB) {
                print("两个碰撞了")
                failed()
            } else {
                print("错误1")
            }
        } else if nodeB == sanjiaoNode {
            if nodeA == circleNode {
                print("插入")
                insert()
            } else if sanjiaoNodeSet.contains(nodeA) {
                print("两个碰撞了")
                failed()
            } else {
                print("错误2")
            }
        }
        canTouch = true
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        print("didEnd")
        
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
