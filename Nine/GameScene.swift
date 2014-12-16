//
//  GameScene.swift
//  Nine
//
//  Created by Alexander Podkopaev on 28.11.14.
//  Copyright (c) 2014 Alexander Podkopaev. All rights reserved.
//

import SpriteKit
import UIKit
import Foundation
import AVFoundation
import iAd

var currentGameState:gameStages!

//Ноды для текста
var labelsNode = SKNode()

//Переменные скорости #leo
let minSpeed:UInt32 = 10 //Минимальная скрость падения
let maxSpeed:UInt32 = 20 //Максимальная скорость падения
var speedModifier:CGFloat = 0 //Не трогать

let maxSpeedforRandomize = maxSpeed - minSpeed //Не трогать

let durationOfExplosion:Int = 30

//Модификаторы размеров цифр #leo
let sizeOfNumbersConts:CGFloat = 1.5


//Всё что связано со шрифтами

//Шрифты для цифр

//Общий модификатор размеров надписей
let sizeStandartforFonts:CGFloat = 2
let sizeStandartforNumOfTouches:CGFloat = 1 //#leo насколько большой шрифт у надписи с количеством касаний
let heightModforNumOfTouches:CGFloat = 1 // #leo как высоко будет надо пальцем цифра






//#leo размер для цифр
let fontSizeMin:CGFloat = 60
let fontSizeMax:CGFloat = 200
let fontSizeForRandomize = fontSizeMax - fontSizeMin //Не трогать

//#leo количество цифр в меню
let numbersForMenu = 5

//#leo частота спавна, меньше = быстрее, менять только первое число
let spawnFrequency:NSTimeInterval = 25 / 100

//#leo альфа диапазон
let minAlpha:CGFloat = 0.3
let alphaForRandomize:CGFloat = (CGFloat(1.0) - minAlpha) * 100

//Для текущего цвета
var currentHUE:CGFloat!
var currentSat:CGFloat!
var currentBr:CGFloat!

var bgHUE:CGFloat!
var bgSat:CGFloat!
var bgBr:CGFloat!

var bgChanging:CGFloat!

var tempHUE:CGFloat!

//Коллизии, маски коллизий
let groundCollisionMask:UInt32 = 0x1 << 0
let numberCollisionMask:UInt32 = 0x1 << 1

//Таймеры
var timerForColoring:NSTimer!
var spawnNumbersTimer:NSTimer!
var timerForPatterns:NSTimer!
var timerForSpeed:NSTimer!
var changingColorTimer:NSTimer!
var timerForBosses:NSTimer!
var tempInvTimer:NSTimer!
var timerForInvAfterMisclick:NSTimer!

var invincibility:Bool = false

//Kingdom of touchess
var numOfTouches = SKLabelNode()
var touchess:Int = 0
var timerForTouches:NSTimer!
var timeOfTouches: Int = 0
let waitingTime:Int = 20 //#leo время ожидания клика в милисекундах
var timerForTouchesIsRunning:Bool = false
var didSucceded:Bool = false

var score:Int = 0

//Patterns
let arrayOfPatterns:[[Int]] = [[1], [1, 2], [2], [3], [1, 3], [2, 3]]
var currentPattern:[Int]!
let patternDurability:NSTimeInterval = 3 //#leo частота изменения паттернов

//Время для перемены скорости
var timeForSpeed: Int = 0
var nextSpeed: CGFloat = 0
let maxRangeForSpeedModifier: CGFloat = 5 //#leo максимальный диапазон при случайном изменении скорости
let speedTimeRange: Int = 10 //Время меняется постепенно каждые <-- секунд

//Таймеры для взрывов
var timeForExplosion = 0
var timerAfterExpl:NSTimer!
var timeToOver:NSTimer!

//Переменные для боссов
var isBonus:Bool = false
var isBoss:Bool = false
var preparedForBoss:Bool = false

var nextBoss:Int!
var timeOfBosses:Int = 0

let minTime:Int = 10 //#leo временной промежуток боссов в секундах
let maxTime:Int = 20
let timeBossForRandom:Int = maxTime - minTime

var currentReward:Int!
let bossRewardMod:Int = 2 //#leo модификаторы награды за боссов и бонусы
let bonusRewardMod:Int = 2

var timeOfInv:Int = 0

let bonusChance:Int = 5  //#leo подразумевается знаменатель то есть сейчас шанс 1/5 при спавне босса

let bossSpeedMod:CGFloat = 1 //#leo модификаторы скорости, использовать очень маленькие числа! типо 0,95
let bonusSpeedMod:CGFloat = 1  //на эти числа домножается относительная скорость поэтому формулы в коде 
let bossFontSizeMod:CGFloat = 1//размер боссов                а тут просто множители
let bonusFontSizeMod:CGFloat = 1 // и бонусов

var sizeForNow:Int!
let arrayOfSizes:[Int] = [10, 30, 50, 70, 100]  //#leo цифры для боссов, можно менять и добавлять
let arrayOfSpeeds:[CGFloat] = [1, 1.3, 1.6, 1.8, 2]  //#leo модификаторы скоростей для боссов
var bossNum:Int = 0

var bossFontSize:CGFloat!

//Переменные для паузы
var gameStateBeforePause:gameStages = gameStages.MainMenu
var boolTimerSpeed:Bool = false
var boolTimerColoring:Bool = false
var boolTimerSpawn:Bool = false
var boolTimerAfterExpl:Bool = false
var boolTimerToOver:Bool = false
var boolTimerChanging:Bool = false
var boolTimerBoss:Bool = false

var wasInvi:Bool = false
var gamePaused:Bool = false

var wasBanner:Bool = false
var overingGame:Bool = false

//Paused node
var pausedNode = SKNode()

//Replay
var notInited:Bool = true

//HUD overlay
var pauseStopTexture = SKTexture(imageNamed: "pauseBB.png")
var pauseReplayTextur = SKTexture(imageNamed: "PPPP.png")
var pauseNode:SKSpriteNode!

var soundNode:SKSpriteNode!
var soundOnTexture = SKTexture(imageNamed: "musicON.png")
var soundOffTexture = SKTexture(imageNamed: "musicOFF.png")

var buttonTouched:Bool = false
let fieldsForPauseButtonMultiplier:CGFloat = 1
let sizeForPauseButtonMultiplier:CGFloat = 1

//Sound
var soundIsOn:Bool = true
var backGroundMusic:AVAudioPlayer!
var bgLoopMusic:NSURL!

//SeguesVars
var restarted:Bool = false
var notFinishRestarted:Bool = true
var restarting:Bool = false

//Аналитика
var wasScore:Int = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Переменные для параметров разных уровней игры
    var difficultyNow:DifficultyLevel!
    var easyDiff:DifficultyLevel!
    var mediumDiff:DifficultyLevel!
    var hardDiff:DifficultyLevel!

    //Ноды объектов
    
    var numbersNode = SKNode()
    
    var groundNode = SKNode()
    
    var explosion = SKShapeNode(circleOfRadius: 50)
    
    var scoreNode = SKLabelNode()
    
    var bossNode = SKLabelNode()
    
    var xTwoNode = SKNode()
    
    var beginRandomizeBosses:Bool = false
    
    var circleOfXTwo:SKShapeNode!
    
    var xTwo:SKLabelNode!

    
    override func didMoveToView(view: SKView) {
        if notInited {
            var notificationCenter:NSNotificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.addObserver(self, selector: Selector("pauseGame"), name: "pauseGamePlease", object: nil)
            notificationCenter.addObserver(self, selector: Selector("pauseView"), name: "pauseViewPlease", object: nil)
            self.addChild(labelsNode)
            self.addChild(numbersNode)
            initEverything()
      //  self.addChild(scoreNode)
            self.physicsWorld.contactDelegate = self
            self.physicsWorld.gravity = CGVectorMake(0, 0)
            notInited = false
            bgLoopMusic = NSBundle.mainBundle().URLForResource("loop", withExtension: "m4a")
            backGroundMusic = AVAudioPlayer(contentsOfURL: bgLoopMusic, error: nil)
            backGroundMusic.numberOfLoops = -1
            backGroundMusic.prepareToPlay()
            soundIsOn = true
        }

    }
    
    func pauseView() {
        self.scene?.paused = true
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        var touch = touches.anyObject() as UITouch
        var location:CGPoint = touch.locationInNode(self)
        var node = self.nodeAtPoint(location)
        if node.name == "pauseButton" {
            buttonTouched = true
            if currentGameState == gameStages.GamePaused {
                Flurry.endTimedEvent("TimeBeforeFirstRestartPressed", withParameters: nil)
                Flurry.logEvent("GameRestarted")
                restartGame()
            } else {
                Flurry.endTimedEvent("TimeBeforeFirstPausePressed", withParameters: nil)
                Flurry.logEvent("GamePaused")
                pauseGame()
            }
        }
        if node.name == "soundNode" {
            buttonTouched = true
            if soundIsOn {
                backGroundMusic.stop()
                soundNode.texture = soundOffTexture
                Flurry.endTimedEvent("TimeBeforeSoundOffStarted", withParameters: nil)
                Flurry.logEvent("SoundOFFButtonPressed")
            } else {
                if currentGameState != gameStages.MainMenu && currentGameState != gameStages.GamePaused {
                backGroundMusic.play()
                }
                soundNode.texture = soundOnTexture
                Flurry.logEvent("SoundONButtonPressed")
            }
            soundIsOn = !soundIsOn
        }

        
        if !buttonTouched  && !wasBanner {
        switch(currentGameState as gameStages) {
        case .MainMenu:
            numbersNode.speed = 1
            currentGameState = .GameGoing
            
            spawnNumbersTimer = NSTimer.scheduledTimerWithTimeInterval(spawnFrequency * NSTimeInterval(self.frame.size.height / 1000), target: self, selector: Selector("spawnNumberFunc"), userInfo: nil, repeats: true)
                boolTimerSpawn = true
            
            timerForPatterns = NSTimer.scheduledTimerWithTimeInterval(patternDurability, target: self, selector: Selector("changePattern"), userInfo: nil, repeats: true)
            
            timerForSpeed = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("modifySpeed"), userInfo: nil, repeats: true)
                boolTimerSpeed = true
            
            timerForBosses = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countBosses"), userInfo: nil, repeats: true)
            boolTimerBoss = true
            
            sizeForNow = arrayOfSizes[bossNum]
            
            labelsNode.removeAllChildren()
            numOfTouches.text = "\(touchess)"
            numOfTouches.fontSize = self.frame.size.width / 1000 * 80 * sizeStandartforNumOfTouches
     //       numOfTouches.position = CGPointMake(100, 100)
            numOfTouches.zPosition = 10
            for num in numbersNode.children {
                if let curNum = num as? SKLabelNode {
                    if curNum.text == "1" {
                        curNum.removeFromParent()
                    }
                }
            }
    //        self.addChild(numOfTouches)
            self.addChild(scoreNode)
            self.addChild(pauseNode)
            soundNode.removeFromParent()
            currentPattern = arrayOfPatterns[Int(arc4random_uniform(UInt32(arrayOfPatterns.count)))]
            nextBoss = Int(arc4random_uniform(UInt32(timeBossForRandom))) + minTime
            backGroundMusic.play()
            self.scene?.paused = false
            setUpFlurry()
       case .GameGoing:
            if !invincibility && !isBoss{
            if !timerForTouchesIsRunning {
                 timerForTouches = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("getEm"), userInfo: nil, repeats: true)
                if difficultyNow.diffNum != easyDiff.diffNum {
                    self.addChild(numOfTouches)
                }
                timerForTouchesIsRunning = true
            }
            timeOfTouches = 0
            touchess++
            numOfTouches.text = "\(touchess)"
                numOfTouches.position = CGPointMake(location.x, location.y + 25 * heightModforNumOfTouches + self.frame.size.width / 1000 * 80 * sizeStandartforNumOfTouches / 2)
            }
            if !invincibility && isBoss {
                affectBoss()
            }
  //     case .GameOver:
        case .GamePaused:
            unPauseGame()

        default:
            currentHUE = currentHUE + 1
        }
        }
        buttonTouched = false
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if currentGameState == gameStages.GamePaused  && !gamePaused{
            pauseGame()

        }
        if restarted && notFinishRestarted {
            restartGame()
            //            restartAfterGO()
            notFinishRestarted = false
        }
 /*       if currentGameState != gameStages.GamePaused && gamePaused {
            unPauseGame()
            self.scene?.paused = false
        } */
    }
    
    func initMainMenu() {
        //Главное меню
        labelsNode.addChild(createTextNode("Tap to begin", xPosition: CGRectGetMidX(self.frame), yPosition: self.frame.size.height / 4, zPosition: 3, fontName: "Helvetica", fontSize: 50, color: UIColor.whiteColor()))
        var xPos:CGFloat = 0
        var yPos:CGFloat = 0
        for var numbers = 0; numbers < numbersForMenu; numbers++ {
            xPos = CGFloat(arc4random_uniform(UInt32(self.frame.width - 200))) + CGFloat(100)
            yPos = CGFloat(arc4random_uniform(UInt32(self.frame.height / 2))) + self.frame.size.height / 2
         //   println("\(xPos) \(yPos)")
            
            createNumber(yPos, xPosition: xPos)
        }
        
        
    }
    
    func createNumber(yPosition:CGFloat, xPosition:CGFloat) {
        //Создание цифр
        var newNumberNode = SKLabelNode()
        
        var fallingAction = SKAction.moveBy(CGVectorMake(0, -((CGFloat(arc4random_uniform(UInt32(maxSpeedforRandomize))) + CGFloat(minSpeed) + speedModifier) * difficultyNow.speedMod) * self.frame.size.height / 1000), duration: 0.1)
        var fallingRepeated = SKAction.repeatActionForever(fallingAction)
        
        var fontSizeForThisNumber = (CGFloat(arc4random_uniform(UInt32(fontSizeForRandomize))) + fontSizeMin) * (self.frame.size.width / 1000) * sizeOfNumbersConts
        //Текстовые параметры
        newNumberNode.text = "\(currentPattern[Int(arc4random_uniform(UInt32(currentPattern.count)))] + (3 * difficultyNow.patternNum))"
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
        
        numbersNode.addChild(newNumberNode)
        
    }
    
    func affectBoss() {
        if isBonus {
            bossNode.text = "\(bossNode.text.toInt()! + 1)"
            bossNode.fontSize = bossNode.fontSize + self.frame.size.width / 900
        } else {
            bossNode.text = "\(bossNode.text.toInt()! - 1)"
            bossNode.fontSize = bossNode.fontSize - (self.frame.size.width / 3 - self.frame.size.width / 1000 * 30) / CGFloat(currentReward)
            if bossNode.text.toInt() == 0 {
                score += currentReward * bossRewardMod
                scoreNode.text = "Score: \(score)"
                resizeScores()
                bossNode.removeFromParent()
                invincibility = true
                tempInvTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("tempInv"), userInfo: nil, repeats: true)
                timerForBosses = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countBosses"), userInfo: nil, repeats: true)
                boolTimerBoss = true
                xTwoNode.alpha = 1
                xTwoNode.runAction(SKAction.sequence([SKAction.waitForDuration(0.2), SKAction.fadeAlphaTo(0, duration: 0.5)]))
            }
        }
    }
    
    func tempInv() {
        timeOfInv++
        if timeOfInv >= 10 {
        if currentGameState != gameStages.GamePaused {
            spawnNumbersTimer = NSTimer.scheduledTimerWithTimeInterval(spawnFrequency * NSTimeInterval(self.frame.size.height / 1000), target: self, selector: Selector("spawnNumberFunc"), userInfo: nil, repeats: true)
        }
        isBoss = false
        isBonus = false
        boolTimerSpawn = true
        invincibility = false
            timeOfInv = 0
            tempInvTimer.invalidate()
        }
    }
    
    func initEverything() {
        //Задание разных общих параметров #leo
        
        //bgChangeMod - скорость изменения цвета фона
        //satForLevel = Saturation, brForLevel = B
        //самое главное - speedMod модификатор скорости падения на разных уровнях сложности
        easyDiff = DifficultyLevel(bgChangeMod: 0.01, minNumber: 1, satForLevel: 0.39, brForLevel: 0.77, diffNum: 1, speedMod: 2, patternNum: 0)
        mediumDiff = DifficultyLevel(bgChangeMod: 0.02, minNumber: 4, satForLevel: 0.56, brForLevel: 0.89, diffNum: 2, speedMod: 1.1, patternNum: 1)
        hardDiff = DifficultyLevel(bgChangeMod: 0.03, minNumber: 7, satForLevel: 0.76, brForLevel: 1, diffNum: 3, speedMod: 0.5, patternNum: 2)
        
        groundNode.position = CGPointMake(CGRectGetMidX(self.frame), 0)
        
        difficultyNow = easyDiff
        
        currentSat = difficultyNow.satForLevel
        currentBr = difficultyNow.brForLevel
        currentHUE = CGFloat(arc4random_uniform(UInt32(100))) / 100
        bgHUE = currentHUE
        
        pauseNode = SKSpriteNode(texture: pauseStopTexture)
        pauseNode.size = CGSizeMake(self.frame.size.width / 10 * sizeForPauseButtonMultiplier, self.frame.size.width / 10 * sizeForPauseButtonMultiplier)
        pauseNode.position = CGPointMake(self.frame.size.width * 14 / 16 * fieldsForPauseButtonMultiplier, self.frame.size.width * 2 / 16 * fieldsForPauseButtonMultiplier)
        pauseNode.name = "pauseButton"
        pauseNode.zPosition = 60
 //       self.addChild(pauseNode)
        soundNode = SKSpriteNode(texture: soundOnTexture)
        soundNode.size = CGSizeMake(self.frame.size.width / 10 * sizeForPauseButtonMultiplier, self.frame.size.width / 10 * sizeForPauseButtonMultiplier)
        soundNode.position = CGPointMake(self.frame.size.width * 2 / 16 * fieldsForPauseButtonMultiplier, self.frame.size.width * 2 / 16 * fieldsForPauseButtonMultiplier)
        soundNode.name = "soundNode"
        soundNode.zPosition = 60
        self.addChild(soundNode)
        
        bgSat = difficultyNow.satForLevel
        bgBr = difficultyNow.brForLevel
        bgChanging = difficultyNow.bgChangeMod
        
        //чтобы в меню не падали цифры сразу
        currentGameState = gameStages.MainMenu
        numbersNode.speed = 0
        
        //Установка начального цвета, hue рандом, остальное можно изменить
        self.backgroundColor = UIColor(hue: bgHUE, saturation: bgSat, brightness: bgBr, alpha: 1)
        
        changingColorTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("changeBGColor"), userInfo: nil, repeats: true)
            boolTimerChanging = true
        
        //Нод земли
        var sizeForGround:CGSize = CGSizeMake(self.frame.size.width, 30)
        groundNode.physicsBody = SKPhysicsBody(rectangleOfSize: sizeForGround)
        groundNode.physicsBody?.dynamic = false
        groundNode.physicsBody?.categoryBitMask = groundCollisionMask
        groundNode.physicsBody?.collisionBitMask = 0
   //     groundNode.physicsBody?.contactTestBitMask = numberCollisionMask
        self.addChild(groundNode)
        
        scoreNode = createTextNode("Score: \(score)", xPosition: self.frame.size.width * 1/16, yPosition: self.frame.size.width * 2/16, zPosition: 10, fontName: "Helvetica", fontSize: 30 * multiForIpad(), color: UIColor.whiteColor())
        
     //   scoreNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        scoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        currentPattern = arrayOfPatterns[0]
        circleOfXTwo = SKShapeNode(circleOfRadius: scoreNode.frame.size.height / 2)
        circleOfXTwo.fillColor = UIColor.whiteColor()
        circleOfXTwo.strokeColor = SKColor.clearColor()
        circleOfXTwo.zPosition = 60
        circleOfXTwo.position = CGPointMake(scoreNode.position.x + scoreNode.frame.size.width + circleOfXTwo.frame.size.width / 2, scoreNode.position.y + scoreNode.frame.size.height / 2)
        xTwo = createTextNode("x2", xPosition: circleOfXTwo.position.x, yPosition: circleOfXTwo.position.y, zPosition: 61, fontName: "Helvetica", fontSize: 20 * multiForIpad(), color: UIColor.blackColor())
        xTwo.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
 //       xTwo.position = CGPointMake(xTwo.position.x, xTwo.position.y - xTwo.frame.size.height / 2)
        
        xTwoNode.addChild(circleOfXTwo)
        xTwoNode.addChild(xTwo)
        xTwoNode.alpha = 0
        self.addChild(xTwoNode)
//        xTwoNode.alpha = 1
        
        nextSpeed = CGFloat(arc4random_uniform(UInt32(20))) - CGFloat(10.0)
        //Инициализация паузы
        var whitescreen = SKSpriteNode(color: UIColor.whiteColor(), size: self.frame.size)
        whitescreen.alpha = 0.5
        whitescreen.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        pausedNode.addChild(whitescreen)
        var playButton = SKSpriteNode(texture: SKTexture(imageNamed: "pauseButton.png"), color: UIColor.greenColor(), size: CGSizeMake(self.frame.size.width / 3, self.frame.size.width / 3))
        playButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        pausedNode.addChild(playButton)
        pausedNode.zPosition = 50
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
            if !invincibility && !isBonus {
                invincibility = true
                spawnNumbersTimer.invalidate()
                boolTimerSpawn = false
                //Меняем уровень на новый
                changeLevel()
                if currentGameState == gameStages.GameOver {
                    invincibility = true
                    bossNode.removeFromParent()
                    letXplosion(contactPos, color: UIColor.whiteColor(), notFinal: false)
                }
                else {
                
            //создаём кольцо "взрыва"
                letXplosion(contactPos, color: self.backgroundColor, notFinal: true)
                }
            }
            if isBonus {
                bossNode.removeFromParent()
                score += bossNode.text.toInt()! * bonusRewardMod
                scoreNode.text = "Score: \(score)"
                resizeScores()
                invincibility = true
                tempInvTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("tempInv"), userInfo: nil, repeats: true)
                timerForBosses = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countBosses"), userInfo: nil, repeats: true)
                xTwoNode.alpha = 1
                xTwoNode.runAction(SKAction.sequence([SKAction.waitForDuration(0.2), SKAction.fadeAlphaTo(0, duration: 0.5)]))
                boolTimerBoss = true
            }
        }
    }
    
    func multiForIpad() -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            return 1.3
        } else {
            return 1
        }
 
    }
    
    func changeBGColor() {
        //Изменение цвета фона, ничего не стоит менять
        bgHUE = bgHUE + bgChanging
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
        //Функция для таймера, спавнит цифры можно чуть подогнать диапазон
        var xPos = CGFloat(arc4random_uniform(UInt32(self.frame.size.width * 19 / 20))) + self.frame.size.width / 40
        createNumber(self.frame.size.height, xPosition: xPos)
    }
    
    func changeLevel() {
        //Проверка и изменение сложности
        switch difficultyNow.diffNum {
        case 1:
            Flurry.endTimedEvent("TimeForFirstLevel", withParameters: NSDictionary(object: (score - wasScore), forKey: "ScoreForFirstLevel"))
            difficultyNow = mediumDiff
            currentBr = difficultyNow.brForLevel
            currentSat = difficultyNow.satForLevel
            numOfTouches.text = "0"
 //           self.addChild(numOfTouches)
            Flurry.logEvent("TimeForSecondLevel", timed: true)
            wasScore = score
        case 2:
            Flurry.endTimedEvent("TimerForSecondLevel", withParameters: NSDictionary(object: (score - wasScore), forKey: "ScoreForSecondLevel"))
            difficultyNow = hardDiff
            currentBr = difficultyNow.brForLevel
            currentSat = difficultyNow.satForLevel
            Flurry.logEvent("TimeForThirdLevel", timed: true)
            wasScore = score
        case 3:
            Flurry.endTimedEvent("TimeForThirdLevel", withParameters: NSDictionary(object: (score - wasScore), forKey: "ScoreForThirdLevel"))
            currentGameState = .GameOver
            Flurry.endTimedEvent("TimeBeforeEnd", withParameters: NSDictionary(object: score, forKey: "TotalScore"))
            backGroundMusic.stop()
        default:
            return
        }
    }
    //Круг от падения цифры
    func letXplosion(position:CGPoint, color: UIColor, notFinal:Bool) {
        explosion.position = position
        if soundIsOn {
            self.runAction(SKAction.playSoundFileNamed("Exp.mp3", waitForCompletion: false))
        }
        var blow = SKAction.scaleBy(23, duration: NSTimeInterval(durationOfExplosion / 10))
        explosion.strokeColor = SKColor.clearColor()
        explosion.fillColor = color
        explosion.zPosition = 5
        if notFinal {
        explosion.runAction(SKAction.sequence([blow, SKAction.customActionWithDuration(0.1, actionBlock: { (node, floatNum) -> Void in
            for number in self.numbersNode.children {
                if let curNum = number as? SKLabelNode {
                    curNum.removeFromParent()
                    
                }
            }
            invincibility = false
        }), SKAction.removeFromParent()]))
        timerForColoring = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("blikingExpl"), userInfo: nil, repeats: true)
            boolTimerColoring = true
        
        timerAfterExpl = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("bgAfterExplosion"), userInfo: nil, repeats: true)
            boolTimerAfterExpl = true
        }
        else {
            explosion.runAction(SKAction.sequence([blow, SKAction.customActionWithDuration(0.1, actionBlock: { (node, CGFloatt) -> Void in
                self.overGame()
            }), SKAction.removeFromParent()]))
            invincibility = true
            timerForColoring?.invalidate()
            boolTimerColoring = false
            boolTimerSpeed = false
            boolTimerSpawn = false
            boolTimerChanging = false
            explosion.fillColor = UIColor.whiteColor()
    //        timeToOver = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(durationOfExplosion / 10), target: self, selector: Selector("overGame"), userInfo: nil, repeats: false)
            overingGame = true
            boolTimerToOver = true
        }
        timerForBosses.invalidate()
        boolTimerBoss = false
        self.addChild(explosion)
    }
    
    func bgAfterExplosion() {
        if timeForExplosion > durationOfExplosion - 5{
            self.backgroundColor = explosion.fillColor
            bgHUE = currentHUE
            bgSat = currentSat
            bgBr = currentBr
            bgChanging = difficultyNow.bgChangeMod
            explosion = SKShapeNode(circleOfRadius: 50 * self.frame.width / 1000 * 3)
            timerForColoring.invalidate()
            boolTimerColoring = false
            if !preparedForBoss {
                spawnNumbersTimer = NSTimer.scheduledTimerWithTimeInterval(spawnFrequency, target: self, selector: Selector("spawnNumberFunc"), userInfo: nil, repeats: true)
            boolTimerSpawn = true
            }
            timeForExplosion = 0
            timerAfterExpl?.invalidate()
            boolTimerAfterExpl = false
            timerForBosses = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countBosses"), userInfo: nil, repeats: true)
            boolTimerBoss = true
            if isBoss {
                isBoss = false
                isBonus = false
            }

        }
        timeForExplosion++
    }
    
    func blikingExpl() {
        currentHUE = currentHUE + difficultyNow.bgChangeMod
        if currentHUE > 1.0 {
            currentHUE = 0.0
        }
        explosion.fillColor = UIColor(hue: currentHUE, saturation: currentSat, brightness: currentBr, alpha: 1)
    }
    
    func getEm() {
        var didHit:Bool = false
        timeOfTouches++
        for numbers in numbersNode.children {
            if let curNum = numbers as? SKLabelNode {
                if curNum.text.toInt() == touchess {
                    didHit = true
                }
            }
        }
        if didHit {
            numOfTouches.fontName = "Helvetica-Bold"
        } else {
            numOfTouches.fontName = "HelveticaNeue-UltraLight"
        }
        if timeOfTouches > waitingTime {
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
                if currentGameState == gameStages.GameOver {
                    spawnNumbersTimer?.invalidate()
                    boolTimerSpawn = false
                    letXplosion(CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2), color: UIColor.whiteColor(), notFinal: false)
                } else {
                    if soundIsOn {
                        self.runAction(SKAction.playSoundFileNamed("Exp.mp3", waitForCompletion: false))
                    }
                currentHUE = 0.99
                bgHUE = 0.99
                bgSat = 1
                bgBr = 1
                for numbers in numbersNode.children {
                    var curNumb:SKLabelNode = numbers as SKLabelNode
                    curNumb.removeFromParent()
                }
                invincibility = true
                spawnNumbersTimer?.invalidate()
                boolTimerSpawn = false
                timerForBosses?.invalidate()
                timerForInvAfterMisclick = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("ouch"), userInfo: nil, repeats: false)
              //  letXplosion(CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)), color: self.backgroundColor, notFinal: true)
            }
            }
            scoreNode.text = "Score: \(score)"
            resizeScores()
            didSucceded = false
            touchess = 0
            timeOfTouches = 0
            numOfTouches.text = "0"
            timerForTouches?.invalidate()
            timerForTouchesIsRunning = false
            numOfTouches.fontName = "HelveticaNeue-UltraLight"
            numOfTouches.removeFromParent()
        }
    }
    
    func createBoss(bonus:Bool, sizeOfBoss:Int) {
        var newBoss = SKLabelNode()
        newBoss.fontName = "Helvetica"
        newBoss.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height)
        newBoss.fontColor = UIColor.blackColor()
        newBoss.zPosition = 5
        if bonus {
            newBoss.text = "0"
            newBoss.fontSize = self.frame.size.width / 40 * bonusFontSizeMod
        } else {
            newBoss.text = "\(sizeOfBoss)"
            bossFontSize = self.frame.size.width / 3 * bossFontSizeMod
            newBoss.fontSize = bossFontSize
        }
        newBoss.physicsBody = SKPhysicsBody(circleOfRadius: 2)
        newBoss.physicsBody?.categoryBitMask = numberCollisionMask
        newBoss.physicsBody?.contactTestBitMask = groundCollisionMask
        newBoss.physicsBody?.collisionBitMask = 0
        bossNode = newBoss
        if bonus {
            bossNode.runAction(SKAction.repeatActionForever(SKAction.moveByX(0, y: (self.frame.size.height / 1000 * -5) * bonusSpeedMod , duration: 0.1)))
        } else {
            bossNode.runAction(SKAction.repeatActionForever(SKAction.moveByX(0, y: ((self.frame.size.height / 1000 / CGFloat(sizeForNow) * 400) * -1) * arrayOfSpeeds[bossNum], duration: 0.1)))
        }
        self.addChild(bossNode)
        timerForTouches?.invalidate()
        numOfTouches.removeFromParent()
        timerForTouchesIsRunning = false
        timeOfTouches = 0
        touchess = 0
        numOfTouches.text = "0"
    }
    
    func countBosses() {
        timeOfBosses++
        if timeOfBosses >= nextBoss {
            nextBoss = Int(arc4random_uniform(UInt32(timeBossForRandom))) + minTime
            switch(Int(arc4random_uniform(UInt32(bonusChance)))) {
            case 0:
                createBoss(true, sizeOfBoss: 0)
                isBonus = true
            default:
                createBoss(false, sizeOfBoss: sizeForNow)
                currentReward = sizeForNow
                if !beginRandomizeBosses {
                    if bossNum < arrayOfSizes.count - 1 {
                        bossNum++
                        } else {
                    beginRandomizeBosses = true
                    bossNum = Int(arc4random_uniform(UInt32(arrayOfSizes.count - 1)))
                    }
                } else {
                    bossNum = Int(arc4random_uniform(UInt32(arrayOfSizes.count - 1)))
                }
                sizeForNow = arrayOfSizes[bossNum]
            }
            for num in numbersNode.children {
                if let number = num as? SKLabelNode {
                    number.removeFromParent()
                }
            }
            isBoss = true
            timeOfBosses = 0
            timerForBosses.invalidate()
            boolTimerBoss = false
            preparedForBoss = false
        }
        if timeOfBosses + 3 >= nextBoss {
            spawnNumbersTimer.invalidate()
            boolTimerSpawn = false
            preparedForBoss = true
        }
    }
    
    func modifySpeed() {
        timeForSpeed++
        if timeForSpeed > speedTimeRange {
            timeForSpeed = 0
            nextSpeed = CGFloat(arc4random_uniform(UInt32(maxRangeForSpeedModifier)))
            switch(arc4random_uniform(UInt32(2))) {
            case 0:
                nextSpeed *= 1
            case 1:
                nextSpeed *= -1
            default:
                nextSpeed *= 1
            }
        }
        speedModifier += nextSpeed / CGFloat(speedTimeRange)
        if speedModifier > 10 || speedModifier < -10 {
            speedModifier = 0
        }
    }
    
    func changePattern() {
        currentPattern = arrayOfPatterns[Int(arc4random_uniform(UInt32(arrayOfPatterns.count)))]
    }
    
    func overGame() {
        timerForSpeed?.invalidate()
        timerForPatterns?.invalidate()
        timerForColoring?.invalidate()
        timerForTouches?.invalidate()
        spawnNumbersTimer?.invalidate()
        timerAfterExpl?.invalidate()
        timeToOver?.invalidate()
        changingColorTimer?.invalidate()
        timerForPatterns?.invalidate()
        timerForBosses?.invalidate()
        tempInvTimer?.invalidate()
        timerForInvAfterMisclick?.invalidate()
        
        currentBr = 0
        currentHUE = 0
        currentSat = 0
        bgHUE = 0
        bgSat = 1
        bgBr = 1
        self.backgroundColor = UIColor.whiteColor()
        
        explosion.removeAllActions()
        explosion.runAction(SKAction.removeFromParent())
        pauseNode.removeFromParent()
        scoreNode.removeFromParent()
        xTwoNode.removeFromParent()
        xTwoNode.alpha = 0
        
        explosion = SKShapeNode(circleOfRadius: 50 * self.frame.width / 1000 * 3)
        
        numOfTouches.removeFromParent()
        timeOfTouches = 0
        timeForSpeed = 0
        timerForTouchesIsRunning = false
        speedModifier = 0
        didSucceded = false
        touchess = 0
        
        timeForExplosion = 0
        
        timeOfInv = 0
        timeOfBosses = 0
        isBoss = false
        isBonus = false
        preparedForBoss = false
        
        currentReward = 0
        bossNum = 0
        sizeForNow = arrayOfSizes[bossNum]
        beginRandomizeBosses = false
        
        boolTimerAfterExpl = false
        boolTimerChanging = false
        boolTimerColoring = false
        boolTimerSpawn = false
        boolTimerAfterExpl = false
        boolTimerToOver = false
        timerForTouchesIsRunning = false
        boolTimerBoss = false
        
        groundNode.removeFromParent()
        scoreNode.removeFromParent()
        explosion.removeFromParent()
        pausedNode.removeFromParent()
        numbersNode.removeFromParent()
        soundNode.removeFromParent()
        pauseNode.removeFromParent()
        labelsNode.removeFromParent()
        bossNode.removeFromParent()

        
        
        if numOfTouches.parent != nil {
            numOfTouches.removeFromParent()
        }
        numbersNode.speed = 0
        bossNode.speed = 0
        for numbers in numbersNode.children {
            if let curNum = numbers as? SKLabelNode {
                curNum.removeFromParent()
            }
        }
        backGroundMusic.stop()
        if !restarting {
        var vc = self.view?.window?.rootViewController
       vc!.performSegueWithIdentifier("overGameSegue", sender: nil)
        }
        restarting = false
    }
    
    func resizeScores() {
        circleOfXTwo.position = CGPointMake(scoreNode.position.x + scoreNode.frame.size.width + circleOfXTwo.frame.size.width / 2, scoreNode.position.y + scoreNode.frame.size.height / 2)
        xTwo.position = CGPointMake(circleOfXTwo.position.x, circleOfXTwo.position.y)

    }
    
    func ouch() {
        invincibility = false
        if currentGameState == gameStages.GamePaused {
            wasInvi = false
        }
        if !preparedForBoss && currentGameState != gameStages.GamePaused && !isBoss {
            spawnNumbersTimer = NSTimer.scheduledTimerWithTimeInterval(spawnFrequency * NSTimeInterval(self.frame.size.height / 1000), target: self, selector: Selector("spawnNumberFunc"), userInfo: nil, repeats: true)
            boolTimerSpawn = true
        }
        if !preparedForBoss && !isBoss {
            boolTimerSpawn = true
        }
        bgSat = currentSat
        bgBr = currentBr
        if currentGameState != gameStages.GamePaused && !isBoss {
            timerForBosses = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countBosses"), userInfo: nil, repeats: true)
        }
        boolTimerBoss = true

    }
    
    func pauseGame() {
        if currentGameState != gameStages.GamePaused {
            gameStateBeforePause = currentGameState
        }
        currentGameState = gameStages.GamePaused
        if boolTimerAfterExpl {
            timerAfterExpl.invalidate()
        }
        if boolTimerChanging {
            changingColorTimer.invalidate()
        }
        if boolTimerColoring {
            timerForColoring.invalidate()
        }
        if boolTimerSpawn {
            spawnNumbersTimer.invalidate()
        }
        if timerForTouchesIsRunning {
 //           touchess = 0
            timerForTouches.invalidate()
  //          timeOfTouches = 0
  //          timerForTouchesIsRunning = false
        }
        if boolTimerSpeed {
            timerForSpeed.invalidate()
        }
  //      if boolTimerToOver {
  //          timeToOver.invalidate()
  //      }
        if boolTimerBoss {
            timerForBosses.invalidate()
        }
        wasInvi = invincibility
        invincibility = true
        self.scene?.paused = true
        gamePaused = true
        pauseNode.texture = pauseReplayTextur
        backGroundMusic.stop()
        numbersNode.speed = 0
        bossNode.speed = 0
        explosion.speed = 0
        scoreNode.removeFromParent()
        self.addChild(soundNode)
        self.addChild(pausedNode)
    }
    
    func unPauseGame() {
        if boolTimerAfterExpl {
            timerAfterExpl = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("bgAfterExplosion"), userInfo: nil, repeats: true)
        }
        if boolTimerChanging {
            changingColorTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("changeBGColor"), userInfo: nil, repeats: true)
        }
        if boolTimerColoring {
            timerForColoring = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("blikingExpl"), userInfo: nil, repeats: true)
        }
        if boolTimerSpawn {
            spawnNumbersTimer = NSTimer.scheduledTimerWithTimeInterval(spawnFrequency * NSTimeInterval(self.frame.size.height / 1000), target: self, selector: Selector("spawnNumberFunc"), userInfo: nil, repeats: true)
        }
        if boolTimerSpeed {
            timerForSpeed = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("modifySpeed"), userInfo: nil, repeats: true)
        }
        if timerForTouchesIsRunning {
            timerForTouches = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("getEm"), userInfo: nil, repeats: true)
        }
        if boolTimerBoss {
            timerForBosses = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countBosses"), userInfo: nil, repeats: true)

        }
     //   if boolTimerToOver {
     //       timeToOver = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(durationOfExplosion / 10), target: self, selector: Selector("overGame"), userInfo: nil, repeats: false)
     //   }
        invincibility = wasInvi
        
        if soundIsOn {
            backGroundMusic.play()
        }
        
        gamePaused = false
        self.scene?.paused = false
        numbersNode.speed = 1
        bossNode.speed = 1
        explosion.speed = 1
        currentGameState = gameStateBeforePause
        pausedNode.removeFromParent()
        soundNode.removeFromParent()
        self.addChild(scoreNode)
        pauseNode.texture = pauseStopTexture
    }
    
    func restartGame() {
   //     unPauseGame()
        stopFlurryTimers()
        restarting = true
        overGame()
        score = 0
        wasScore = 0
        scoreNode.text = "Score: 0"
        resizeScores()
        numOfTouches.text = "0"
        difficultyNow = easyDiff
        self.addChild(groundNode)
        self.addChild(numbersNode)
        self.addChild(scoreNode)
        self.addChild(soundNode)
        self.addChild(pauseNode)
//        self.addChild(labelsNode)
        
        currentHUE = CGFloat(arc4random_uniform(UInt32(100))) / 100
        bgHUE = currentHUE
        currentBr = difficultyNow.brForLevel
        bgBr = currentBr
        currentSat = difficultyNow.satForLevel
        bgSat = currentSat
        currentPattern = arrayOfPatterns[1]
        timeForSpeed = 0
        nextSpeed = CGFloat(arc4random_uniform(UInt32(maxRangeForSpeedModifier)))
        
        changingColorTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("changeBGColor"), userInfo: nil, repeats: true)
        boolTimerChanging = true
        spawnNumbersTimer = NSTimer.scheduledTimerWithTimeInterval(spawnFrequency * NSTimeInterval(self.frame.size.height / 1000), target: self, selector: Selector("spawnNumberFunc"), userInfo: nil, repeats: true)
        boolTimerSpawn = true
        timerForSpeed = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("modifySpeed"), userInfo: nil, repeats: true)
        boolTimerSpeed = true
        timerForPatterns = NSTimer.scheduledTimerWithTimeInterval(patternDurability, target: self, selector: Selector("changePattern"), userInfo: nil, repeats: true)
        
        timerForBosses = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countBosses"), userInfo: nil, repeats: true)
        boolTimerBoss = true

        
        currentGameState = gameStages.GameGoing
        numbersNode.speed = 1
        bossNode.speed = 1
        explosion.speed = 1
        gamePaused = false
        
        self.scene?.paused = false
        pauseNode.texture = pauseStopTexture
        
        invincibility = false
        
        if soundIsOn {
            backGroundMusic.play()
        }
  //      self.requestInterstitialAdPresentation(self)
        Flurry.logEvent("TimeForFirstLevel", timed: true)
        Flurry.logEvent("TimeBeforeEnd", timed: true)
        soundNode.removeFromParent()
        self.addChild(xTwoNode)
        resizeScores()

    }
    
    func setUpFlurry() {
        Flurry.logEvent("TimeBeforeFirstPausePressed", timed: true)
        Flurry.logEvent("TimeBeforeFirstRestartPressed", timed: true)
        Flurry.logEvent("TimeBeforeEnd", timed: true)
        Flurry.logEvent("TimeForFirstLevel", timed: true)
        Flurry.logEvent("TimeBeforeSoundOffStarted", timed: true)
    }
    
    func stopFlurryTimers() {
        Flurry.endTimedEvent("TimeForFirstLevel", withParameters: nil)
        Flurry.endTimedEvent("TimeForSecondLevel", withParameters: nil)
        Flurry.endTimedEvent("TimeForThirdLevel", withParameters: nil)
        Flurry.endTimedEvent("TimeBeforeEnd", withParameters: nil)
    }
}
