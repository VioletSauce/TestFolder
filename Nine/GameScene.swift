//
//  GameScene.swift
//  Nine
//
//  Created by Alexander Podkopaev on 28.11.14.
//  Copyright (c) 2014 Alexander Podkopaev. All rights reserved.
//

import SpriteKit
import UIKit

//Переменные для параметров разных уровней игры
var difficultyNow:DifficultyLevel!
var easyDiff:DifficultyLevel!
var mediumDiff:DifficultyLevel!
var hardDiff:DifficultyLevel!

var currentGameState:gameStages!

//Ноды объектов

var numbersNode = SKNode()

var groundNode = SKNode()

var explosion = SKShapeNode(circleOfRadius: 50)

var scoreNode = SKLabelNode()

//Ноды для текста
var labelsNode = SKNode()

//Переменные скорости #leo
let minSpeed:UInt32 = 5 //Минимальная скрость падения
let maxSpeed:UInt32 = 10 //Максимальная скорость падения
var speedModifier:CGFloat = 0 //Не трогать

let maxSpeedforRandomize = maxSpeed - minSpeed //Не трогать

let durationOfExplosion: NSTimeInterval = 3

//Модификаторы размеров #leo
let sizeOfNumbersConts:CGFloat = 2


//Всё что связано со шрифтами

//Шрифты для цифр

//Общий модификатор размеров
let sizeStandartforFonts:CGFloat = 2

//#leo размер для цифр
let fontSizeMin:CGFloat = 60
let fontSizeMax:CGFloat = 200
let fontSizeForRandomize = fontSizeMax - fontSizeMin //Не трогать

//#leo количество цифр в меню
let numbersForMenu = 5

//#leo частота спавна, меньше = быстрее, менять только первое число
let spawnFrequency:NSTimeInterval = 15 / 100

//#leo альфа диапазон
let minAlpha:CGFloat = 0.3
let alphaForRandomize:CGFloat = (CGFloat(1.0) - minAlpha) * 100

//Для текущего цвета
var currentHUE:CGFloat = CGFloat(arc4random_uniform(100)) / 100
var currentSat:CGFloat!
var currentBr:CGFloat!

var bgHUE:CGFloat = currentHUE
var bgSat:CGFloat!
var bgBr:CGFloat!

var bgChanging:CGFloat!

var tempHUE:CGFloat!

//Коллизии, маски коллизий
let groundCollisionMask:UInt32 = 0x1 << 0
let numberCollisionMask:UInt32 = 0x1 << 1

//Таймер снаружи, потому что я не умею с ними работать
var timerForColoring:NSTimer!
var spawnNumbersTimer:NSTimer!

var invincibility:Bool = false

//Tests
var numOfTouches = SKLabelNode()
var touchess:Int = 0
var timerForTouches:NSTimer!
var timeOfTouches: Int = 0
var timerForTouchesIsRunning:Bool = false
var didSucceded:Bool = false
var score:Int = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    override func didMoveToView(view: SKView) {
        self.addChild(labelsNode)
        self.addChild(numbersNode)
      //  self.addChild(scoreNode)
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        initEverything()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        switch(currentGameState as gameStages) {
        case .MainMenu:
            numbersNode.speed = 1
            currentGameState = .GameGoing
            
            spawnNumbersTimer = NSTimer.scheduledTimerWithTimeInterval(spawnFrequency, target: self, selector: Selector("spawnNumberFunc"), userInfo: nil, repeats: true)
            labelsNode.removeAllChildren()
            numOfTouches.text = "\(touchess)"
            numOfTouches.position = CGPointMake(100, 100)
            numOfTouches.zPosition = 10
            self.addChild(numOfTouches)
            self.addChild(scoreNode)
        case .GameGoing:
            if !invincibility {
            if !timerForTouchesIsRunning {
                 timerForTouches = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("getEm"), userInfo: nil, repeats: true)
                timerForTouchesIsRunning = true
            }
            timeOfTouches = 0
            touchess++
            numOfTouches.text = "\(touchess)"
            }
   //     case .GameOver:
            
        default:
            currentHUE++
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func initMainMenu() {
        //Главное меню
        labelsNode.addChild(createTextNode("Tap to begin", xPosition: CGRectGetMidX(self.frame), yPosition: self.frame.size.height / 4, zPosition: 3, fontName: "Helvetica", fontSize: 50, color: UIColor.whiteColor()))
        var xPos:CGFloat = 0
        var yPos:CGFloat = 0
        for var numbers = 0; numbers < numbersForMenu; numbers++ {
            xPos = CGFloat(arc4random_uniform(UInt32(self.frame.width - 200))) + 100
            yPos = CGFloat(arc4random_uniform(UInt32(self.frame.height / 2 + 100))) + self.frame.size.height / 2 - 100
         //   println("\(xPos) \(yPos)")
            
            createNumber(yPos, xPosition: xPos)
        }
        
        
    }
    
    func createNumber(yPosition:CGFloat, xPosition:CGFloat) {
        //Создание цифр
        var newNumberNode = SKLabelNode()
        
        var fallingAction = SKAction.moveBy(CGVectorMake(0, -(CGFloat(arc4random_uniform(maxSpeedforRandomize)) + CGFloat(minSpeed) + speedModifier) * difficultyNow.speedMod), duration: 0.1)
        var fallingRepeated = SKAction.repeatActionForever(fallingAction)
        
        var fontSizeForThisNumber = (CGFloat(arc4random_uniform(UInt32(fontSizeForRandomize))) + fontSizeMin) * (self.frame.size.width / 1000) * sizeOfNumbersConts
        //Текстовые параметры
        newNumberNode.text = "\(Int(arc4random_uniform(UInt32(3))) + difficultyNow.minNumber)"
        newNumberNode.fontName = "Helvetica-Bold" //#leo шрифт цифр, если всё же решишь поменять
        newNumberNode.fontSize = fontSizeForThisNumber
        newNumberNode.fontColor = UIColor.whiteColor()
        newNumberNode.position = CGPointMake(xPosition, yPosition)
        newNumberNode.zPosition = 2
        newNumberNode.alpha = CGFloat(arc4random_uniform(UInt32(alphaForRandomize))) / 100 + minAlpha
        
        newNumberNode.runAction(fallingRepeated)
        
        //Collisions
        newNumberNode.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        newNumberNode.physicsBody?.dynamic = true
        newNumberNode.physicsBody?.categoryBitMask = numberCollisionMask
        newNumberNode.physicsBody?.collisionBitMask = 0
        newNumberNode.physicsBody?.contactTestBitMask = groundCollisionMask
       // newNumberNode.physicsBody?.collisionBitMask = numberCollisionMask
        
        numbersNode.addChild(newNumberNode)
        
    }
    
    func initEverything() {
        //Задание разных общих параметров #leo
        
        //bgChangeMod - скорость изменения цвета фона
        //satForLevel = Saturation, brForLevel = B
        easyDiff = DifficultyLevel(bgChangeMod: 0.01, minNumber: 1, satForLevel: 0.39, brForLevel: 0.77, diffNum: 1, speedMod: 2)
        mediumDiff = DifficultyLevel(bgChangeMod: 0.02, minNumber: 4, satForLevel: 0.56, brForLevel: 0.89, diffNum: 2, speedMod: 1.5)
        hardDiff = DifficultyLevel(bgChangeMod: 0.03, minNumber: 7, satForLevel: 0.76, brForLevel: 1, diffNum: 3, speedMod: 1)
        
        difficultyNow = easyDiff
        
        currentSat = difficultyNow.satForLevel
        currentBr = difficultyNow.brForLevel
        
        bgSat = difficultyNow.satForLevel
        bgBr = difficultyNow.brForLevel
        bgChanging = difficultyNow.bgChangeMod
        
        //чтобы в меню не падали цифры сразу
        currentGameState = gameStages.MainMenu
        numbersNode.speed = 0
        
        //Установка начального цвета, hue рандом, остальное можно изменить #leo
        self.backgroundColor = UIColor(hue: bgHUE, saturation: bgSat, brightness: bgBr, alpha: 1)
        
        var changingColorTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("changeBGColor"), userInfo: nil, repeats: true)
        
        //Нод земли
        groundNode.position = CGPointMake(CGRectGetMidX(self.frame), CGFloat(maxSpeed) / 2 + 1)
        groundNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, CGFloat(maxSpeed) + 1))
        groundNode.physicsBody?.dynamic = false
        groundNode.physicsBody?.categoryBitMask = groundCollisionMask
        groundNode.physicsBody?.collisionBitMask = 0
   //     groundNode.physicsBody?.contactTestBitMask = numberCollisionMask
        self.addChild(groundNode)
        
        scoreNode = createTextNode("\(score)", xPosition: self.frame.size.width - 100, yPosition: 100, zPosition: 10, fontName: "Helvetica", fontSize: 50, color: UIColor.whiteColor())
        
        initMainMenu()
        
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == groundCollisionMask && contact.bodyB.categoryBitMask == numberCollisionMask) || (contact.bodyB.categoryBitMask == groundCollisionMask && contact.bodyA.categoryBitMask == numberCollisionMask){
            var contactPos:CGPoint!
            if contact.bodyB.categoryBitMask == numberCollisionMask {
                contact.bodyB.node?.removeFromParent()
                contactPos = contact.contactPoint
            } else if contact.bodyA.categoryBitMask == numberCollisionMask {
                contact.bodyA.node?.removeFromParent()
                contactPos = contact.contactPoint
            }
            if !invincibility {
                invincibility = true
                spawnNumbersTimer.invalidate()
            //Меняем уровень на новый
            changeLevel()
            
            //создаём кольцо "взрыва"
                letXplosion(contactPos, color: self.backgroundColor, notFinal: true)
            }
        }
    }
    
    func changeBGColor() {
        //Изменение цвета фона, ничего не стоит менять
        bgHUE += bgChanging
        if bgHUE > 1.0 {
            bgHUE = 0.0
        }
        self.backgroundColor = UIColor(hue: bgHUE, saturation: bgSat, brightness: bgBr, alpha: 1)
    }
    
    func createTextNode(textString:String, xPosition:CGFloat, yPosition:CGFloat, zPosition:CGFloat, fontName:String, fontSize:CGFloat, color:UIColor) -> SKLabelNode {
        //Создание текстового нода(для меню, очков, просто быстрое сокращение)
        var newLabelNode = SKLabelNode()
        newLabelNode.text = textString
        newLabelNode.fontName = fontName
        newLabelNode.fontSize = fontSize * sizeStandartforFonts * self.frame.size.width / 1000
        newLabelNode.fontColor = color
        newLabelNode.position = CGPointMake(xPosition, yPosition)
        newLabelNode.zPosition = zPosition
        

        return newLabelNode
    }
    
    func spawnNumberFunc() {
        //Функция для таймера, спавнит цифыр можно чуть подогнать диапазон
        var xPos = CGFloat(arc4random_uniform(UInt32(self.frame.size.width - 60))) + 30
        createNumber(self.frame.size.height, xPosition: xPos)
    }
    
    func changeLevel() {
        switch difficultyNow.diffNum {
        case 1:
            difficultyNow = mediumDiff
            currentBr = difficultyNow.brForLevel
            currentSat = difficultyNow.satForLevel
        case 2:
            difficultyNow = hardDiff
            currentBr = difficultyNow.brForLevel
            currentSat = difficultyNow.satForLevel
        case 3:
            println("game over")
            currentGameState = .GameOver
        default:
            return
        }
    }
    //Круг от падения цифры
    func letXplosion(position:CGPoint, color: UIColor, notFinal:Bool) {
        explosion.position = position
        var blow = SKAction.scaleBy(23, duration: durationOfExplosion)
        explosion.strokeColor = SKColor.clearColor()
        explosion.fillColor = color
        explosion.zPosition = 5
        explosion.runAction(SKAction.sequence([blow, SKAction.removeFromParent()]))
        if notFinal {
        timerForColoring = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("blikingExpl"), userInfo: nil, repeats: true)
        self.addChild(explosion)
        
        var timerAfterExpl = NSTimer.scheduledTimerWithTimeInterval(durationOfExplosion, target: self, selector: Selector("bgAfterExplosion"), userInfo: nil, repeats: false)
        }
        else {
            
        }
    }
    
    func bgAfterExplosion() {
        self.backgroundColor = explosion.fillColor
        bgHUE = currentHUE
        bgSat = currentSat
        bgBr = currentBr
        bgChanging = difficultyNow.bgChangeMod
        explosion = SKShapeNode(circleOfRadius: 50 * self.frame.width / 1000 * 3)
        timerForColoring.invalidate()
        spawnNumbersTimer = NSTimer.scheduledTimerWithTimeInterval(spawnFrequency, target: self, selector: Selector("spawnNumberFunc"), userInfo: nil, repeats: true)
        for number in numbersNode.children {
            if let curNum = number as? SKLabelNode {
                curNum.removeFromParent()
            }
        }
        invincibility = false
    }
    
    func blikingExpl() {
        currentHUE = currentHUE + difficultyNow.bgChangeMod
        if currentHUE > 1.0 {
            currentHUE = 0.0
        }
        explosion.fillColor = UIColor(hue: currentHUE, saturation: currentSat, brightness: currentBr, alpha: 1)
    }
    
    func getEm() {
        timeOfTouches++
        if timeOfTouches > 20 {
            for numbers in numbersNode.children {
                if let curNum = numbers as? SKLabelNode {
                    if curNum.text.toInt() == touchess {
                        score += curNum.text.toInt()!
                        curNum.removeFromParent()
                        didSucceded = true
                    }
                }
            }
            if !didSucceded && !invincibility {
                changeLevel()
                currentHUE = 0.99
                bgHUE = 0.99
                for numbers in numbersNode.children {
                    var curNumb:SKLabelNode = numbers as SKLabelNode
                    curNumb.removeFromParent()
                }
              //  letXplosion(CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)), color: self.backgroundColor, notFinal: true)
            }
            scoreNode.text = toString(score)
            didSucceded = false
            touchess = 0
            timeOfTouches = 0
            timerForTouches.invalidate()
            timerForTouchesIsRunning = false
        }
    }
}
