//
//  Twitter: @MartinRogalla
//  EmaiL: email@martinrogalla.com
//
//  Created by Martin Rogalla.
//
//  Updated to Swift 4 by Dmitry Sokolov

import UIKit

public class SnowflakesView : UIView {
    
    var animator1 : UIDynamicAnimator?
    var animator2 : UIDynamicAnimator?
    var snowflakes: [UIView] = []
    var gravityBehaviour1 = UIGravityBehavior()
    var gravityBehaviour2 = UIGravityBehavior()
    var gravityPullRight = false
    
    // added:
    var snowflakeMinSize: Int = 2
    var snowflakeMaxSize: Int = 4
    
    var timer : Timer?
    
    override public init (frame : CGRect) {
        super.init(frame : frame)
        initGravityAnimator()
        timer = Timer.scheduledTimer(timeInterval: Double(arc4random_uniform(100))/100, target: self, selector: #selector(SnowflakesView.changeGravityDirection), userInfo: nil, repeats: true)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    
    /// Let the client to specify the size of a snowflake
    public func setSnowflakeSize(minSize: Int, maxSize: Int) {
        self.snowflakeMinSize = minSize
        self.snowflakeMaxSize = maxSize
    }
    
    
    
    func initGravityAnimator() {
        gravityBehaviour1.magnitude = 0.10
        gravityBehaviour1.gravityDirection.dx = 0.25
        gravityBehaviour2.magnitude = 0.20
        gravityBehaviour2.gravityDirection.dx = 0.25
        
        self.animator1 = UIDynamicAnimator(referenceView: self)
        self.animator1?.addBehavior(gravityBehaviour1)
        
        self.animator2 = UIDynamicAnimator(referenceView: self)
        self.animator2?.addBehavior(gravityBehaviour2)
    }
    
    func changeGravityDirection() {
        DispatchQueue.main.async {
            if self.gravityPullRight { // Simulate wind, by changing gravity direction.
                self.gravityBehaviour1.gravityDirection.dx += 0.4
                self.gravityBehaviour2.gravityDirection.dx += 0.5
            } else {
                self.gravityBehaviour1.gravityDirection.dx -= 0.4
                self.gravityBehaviour2.gravityDirection.dx -= 0.5
            }
            self.gravityPullRight = !self.gravityPullRight
        }
        if (self.snowflakes.count < 150) {
            DispatchQueue.main.async {
                self.addNewSnowflake()
            }
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: Double(arc4random_uniform(100))/100, target: self, selector: #selector(SnowflakesView.changeGravityDirection), userInfo: nil, repeats: true)
    }
    
    func addNewSnowflake() {
        let snowflakePosition = CGPoint(x: Int(arc4random_uniform(UInt32(self.bounds.width)) + 1), y: -Int(arc4random_uniform(200)))
        let snowflake = Snowflake(position: snowflakePosition, minimumSize: self.snowflakeMinSize, maximumSize: self.snowflakeMaxSize)
        self.addSubview(snowflake)
        
        // Randomly assign the snowfalke to one of the two gravity environments.
        if(Int(arc4random_uniform(2)) > 0) {
            self.gravityBehaviour1.addItem(snowflake)
        } else {
            self.gravityBehaviour2.addItem(snowflake)
        }
        
        snowflakes.append(snowflake)
        startSnowflakeLifecycle(snowflake: snowflake)
    }
    
    func startSnowflakeLifecycle(snowflake: UIView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(arc4random_uniform(100) + 500) / 100) {
            // Remove the snowflake.
            self.gravityBehaviour1.removeItem(snowflake)
            self.gravityBehaviour2.removeItem(snowflake)
            snowflake.removeFromSuperview()
            self.snowflakes = self.snowflakes.filter { item in return item != snowflake }
            
            // Spawn a new snowflake
            self.addNewSnowflake()
        }
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        if hitView == self {
            return nil
        }
        
        return hitView
    }
}

