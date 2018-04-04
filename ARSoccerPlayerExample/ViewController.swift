import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var ballNode = SCNNode()
    var anchors: [ARAnchor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        sceneView.scene = scene
        
        ballNode = make2dNode(image: #imageLiteral(resourceName: "soccer-ball"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func make2dNode(image: UIImage, width: CGFloat = 0.1, height: CGFloat = 0.1) -> SCNNode {
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial!.diffuse.contents = image
        let node = SCNNode(geometry: plane)
        node.constraints = [SCNBillboardConstraint()]
        return node
    }
    
    private func startBouncing() {
        guard let first = anchors.first, let start = sceneView.node(for: first),
            let last = anchors.last, let end = sceneView.node(for: last)
            else {
                return
        }
        
        if ballNode.parent == nil {
            sceneView.scene.rootNode.addChildNode(ballNode)
        }
        
        let animation = CABasicAnimation(keyPath: #keyPath(SCNNode.transform))
        animation.fromValue = start.transform
        animation.toValue = end.transform
        animation.duration = 1
        animation.autoreverses = true
        animation.repeatCount = .infinity
        ballNode.removeAllAnimations()
        ballNode.addAnimation(animation, forKey: nil)
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let player = make2dNode(image: #imageLiteral(resourceName: "cartoon-soccer-player-edited"))
        node.addChildNode(player)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if anchors.count > 1 {
            startBouncing()
            return
        }
        
        if let currentFrame = sceneView.session.currentFrame {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.3
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
            anchors.append(anchor)
        }
    }
}
