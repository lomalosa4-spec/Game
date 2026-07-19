import SceneKit
import UIKit

class GameScene: SCNScene {
    var cameraNode = SCNNode()
    var player = SCNNode()
    var enemies: [SCNNode] = []
    var ammo = 30
    var score = 0
    var health = 100
    var isReloading = false
    
    override init() {
        super.init()
        setupScene()
        setupPlayer()
        setupEnemies()
        startGameLoop()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupScene() {
        // Земля
        let ground = SCNNode(geometry: SCNPlane(width: 100, height: 100))
        ground.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
        ground.position = SCNVector3(0, 0, 0)
        ground.rotation = SCNVector4(1, 0, 0, -Float.pi / 2)
        rootNode.addChildNode(ground)
        
        // Стены
        for i in -20...20 where i % 5 == 0 {
            let wall = SCNNode(geometry: SCNBox(width: 0.5, height: 4, length: 3, chamferRadius: 0))
            wall.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
            wall.position = SCNVector3(Float(i), 2, -20)
            rootNode.addChildNode(wall)
            
            let wall2 = wall.clone()
            wall2.position = SCNVector3(Float(i), 2, 20)
            rootNode.addChildNode(wall2)
        }
        
        // Освещение
        let light = SCNNode()
        light.light = SCNLight()
        light.light?.type = .directional
        light.position = SCNVector3(0, 20, 10)
        rootNode.addChildNode(light)
        
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor.darkGray
        rootNode.addChildNode(ambient)
    }
    
    func setupPlayer() {
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 1.7, 10)
        rootNode.addChildNode(cameraNode)
        
        // Оружие
        let gun = SCNNode(geometry: SCNBox(width: 0.05, height: 0.1, length: 0.3, chamferRadius: 0))
        gun.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
        gun.position = SCNVector3(0.2, -0.3, -0.6)
        cameraNode.addChildNode(gun)
    }
    
    func setupEnemies() {
        for i in 0..<5 {
            let enemy = SCNNode(geometry: SCNCapsule(capRadius: 0.25, height: 1.5))
            enemy.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            let x = Float.random(in: -15...15)
            let z = Float.random(in: -15...15)
            enemy.position = SCNVector3(x, 0.75, z)
            enemy.name = "enemy_\(i)"
            rootNode.addChildNode(enemy)
            enemies.append(enemy)
        }
    }
    
    func startGameLoop() {
        let moveGesture = UIPanGestureRecognizer()
        let shootGesture = UITapGestureRecognizer()
        
        // Добавляем на вьюху позже
    }
    
    func shoot() {
        guard ammo > 0, !isReloading else { return }
        ammo -= 1
        
        // Raycast
        let ray = cameraNode.position
        let direction = cameraNode.worldFront
        
        // Простая проверка попадания
        for enemy in enemies {
            let dist = enemy.position - ray
            let length = sqrt(dist.x * dist.x + dist.y * dist.y + dist.z * dist.z)
            if length < 30 {
                let dot = abs(dist.x * direction.x + dist.y * direction.y + dist.z * direction.z) / length
                if dot > 0.95 {
                    // Попадание
                    enemy.removeFromParentNode()
                    if let idx = enemies.firstIndex(of: enemy) {
                        enemies.remove(at: idx)
                    }
                    score += 1
                    spawnEnemy()
                    break
                }
            }
        }
        
        if ammo == 0 { reload() }
    }
    
    func reload() {
        isReloading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.ammo = 30
            self.isReloading = false
        }
    }
    
    func spawnEnemy() {
        let enemy = SCNNode(geometry: SCNCapsule(capRadius: 0.25, height: 1.5))
        enemy.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        enemy.position = SCNVector3(Float.random(in: -15...15), 0.75, Float.random(in: -15...15))
        enemy.name = "enemy_\(enemies.count)"
        rootNode.addChildNode(enemy)
        enemies.append(enemy)
    }
}

func -(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
}
