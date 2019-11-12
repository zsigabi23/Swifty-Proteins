//
//  ProteinViewController.swift
//  Swifty Proteins
//
//  Created by Kondelelani NEDZINGAHE on 2019/10/27.
//  Copyright © 2019 Kondelelani NEDZINGAHE. All rights reserved.
//

import UIKit
import SceneKit
import SwiftyJSON
import Alamofire
import CoreMotion
import Social

class ProteinViewController: UIViewController, SCNSceneRendererDelegate {
    
    var scnScene: SCNScene!;
    var camNode: SCNNode!;
    var objRotTime: TimeInterval = 0;
    var hidrogen: Bool = true;
    
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var selectedAtom: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBAction func share(_ sender: Any) {
        
        let bounds = UIScreen.main.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        self.view.drawHierarchy(in: bounds, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let activityViewController = UIActivityViewController(activityItems: [img!], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .airDrop, .copyToPasteboard, .mail, .assignToContact]
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func hidrogenButt(_ sender: Any) {
        hidrogen = !hidrogen;
        
        if hidrogen {
            for atom in Data.atoms{
                if atom.symbol == "H"{
                    addAtom(atom: atom);
                }
            }
            addLinks(links: Data.hLinks);
        }
        else{
            for node in scnScene.rootNode.childNodes{
                if node.name == "H"{
                    node.removeFromParentNode();
                }
            }
        }
    }
    
    func initView(){
        scnView.autoenablesDefaultLighting = true;
        scnView.allowsCameraControl = true;
        scnView.delegate = self;

//        let pinchingGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchingGesture(_:)))
//
//        scnView.addGestureRecognizer(pinchingGesture);
    }
    
    func initScene(){
        scnScene = SCNScene();
        scnView.scene = scnScene;
        scnView.isPlaying = true;
    }
    
    func initCam(){
        camNode = SCNNode();
        camNode.camera = SCNCamera();
        camNode.position = SCNVector3(x: 0, y: 0, z: 15);
        
        scnScene.rootNode.addChildNode(camNode);
    }
    
    func addAtom(atom: Atom){
        let atomGeometry: SCNGeometry = SCNSphere(radius: 0.3);
        atomGeometry.materials.first?.diffuse.contents = atom.color;
        
        let atomNode = SCNNode(geometry: atomGeometry);
        atomNode.position = SCNVector3(x: atom.x, y: atom.y, z: atom.z);
        atomNode.name = atom.symbol;
        scnScene.rootNode.addChildNode(atomNode);
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        if time > objRotTime{
//            objRotTime = time + 0.005;
//            camNode.eulerAngles = SCNVector3Make(0, 0, Float(objRotTime));
//        }
//    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!;
        let loc = touch.location(in: scnView);
        let hitList = scnView.hitTest(loc, options: nil);
        
        if let hitObj = hitList.first{
            let node = hitObj.node;
            selectedAtom.text = "Selected element: " + (node.name ?? "");
            
        }
    } 
    
    func showErrAlert(msg: String){
        let alert = UIAlertController(title: "ERROR", message: msg, preferredStyle: .alert);
        let action = UIAlertAction(title: "OK", style: .cancel, handler: handleError(alert:));
        
        alert.addAction(action);
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil);
        }
    }
    
    func handleError(alert: UIAlertAction){
        performSegue(withIdentifier: "backToLigands", sender: self);
    }
    
    @objc func pinchingGesture(_ gesture: UIPinchGestureRecognizer){
        let view = gesture.view as! SCNView;
        
        switch gesture.state{
        case .began:
            break;
        case .changed:
            view.transform.scaledBy(x: view.bounds.size.width * gesture.scale, y: view.bounds.size.height * gesture.scale);
            break;
        case .ended:
            break;
        case .possible:
            break;
        case .cancelled:
            break;
        case .failed:
            break;
        @unknown default:
            break;
        }
    }
    
    func getPDB(name: String){
        let n = name + "_model.pdb"
        if let url = URL(string: "http://files.rcsb.org/ligands/" + name.prefix(1) + "/" + name + "/" + n){
        
            let request = URLRequest(url: url)
            let destination: DownloadRequest.DownloadFileDestination = {_,_ in
                let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0];
                let fileUrl = docUrl.appendingPathComponent(n)
                
                return (fileUrl, [.removePreviousFile]);
            }
            
            Alamofire.download(request, to: destination).response{
                response in
                
                if let err = response.error{
                    self.showErrAlert(msg: "Invalid Ligand")
                    print(err);
                }else if let resp = response.destinationURL{
                    
                    do{
                        let content = try String(contentsOf: resp);
                        let lines = content.components(separatedBy: "\n");
                        var sumX: Float = 0.0;
                        var sumY: Float = 0.0;
                        var count: Int = 0;
                        var centerX: Float = 0.0;
                        var centerY: Float = 0.0;
                        var closestZ: Float = 0.0;
                        
                        for line in lines{
                            if line.contains("ATOM"){
                                let lineContent = line.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
                                let atomInfo = lineContent.filter({$0 != ""});
                                let atom = Atom(id: atomInfo[1], symbol: atomInfo[11], x: (atomInfo[6] as NSString).floatValue, y: (atomInfo[7] as NSString).floatValue, z: (atomInfo[8] as NSString).floatValue)
                                Data.atoms.append(atom);
                                self.addAtom(atom: atom)
                                
                                sumX += atom.x;
                                sumY += atom.y;
                                closestZ = atom.z > closestZ ? atom.z : closestZ;
                                count += 1;
                            }
                            else if line.contains("CONECT"){
                                let conns = line.components(separatedBy: NSCharacterSet.whitespaces).filter({$0 != ""});
                            
                                for c in 2..<conns.count{
                                    let link = Link(from: conns[1], to: conns[c]);
                                
                                    if !self.checkIfExist(link: link){
                                        Data.links.append(link);
                                    }
                                }
                            }
                            centerX = sumX / Float(count);
                            centerY = sumY / Float(count);
                            self.camNode.position = SCNVector3(centerX, centerY, closestZ + 20);
                        }
                        
                        if Data.atoms.count == 0{
                            self.showErrAlert(msg: "Invalid Ligand");
                        }
                        self.addLinks(links: Data.links);
                    }catch(_){
                        self.showErrAlert(msg: "Invalid Ligand");
                    }
                }
            }
        }
        else{
            showErrAlert(msg: "Invalid Ligand")
        }
    }
    
    func checkIfExist(link: Link) -> Bool{
        for linkItem in Data.links{
            if link == linkItem{
                return true;
            }
        }
        return false;
    }
    
    func addLinks(links: [Link]){
        for link in Data.links{
            let start = Data.atoms.filter({$0.id == link.from});
            let end = Data.atoms.filter({$0.id == link.to});
            
            if start[0].symbol == "H" && end[0].symbol == "H"{
                Data.hLinks.append(link);
            }
            
            if start.count == 1 && end.count == 1{
                let startPos = SCNVector3(start[0].x, start[0].y, start[0].z)
                let endPos = SCNVector3(end[0].x, end[0].y, end[0].z)
                let height = CGFloat(GLKVector3Distance(SCNVector3ToGLKVector3(startPos), SCNVector3ToGLKVector3(endPos)));

                let cylinderGeometry = SCNCylinder(radius: 0.1, height: height);
                cylinderGeometry.firstMaterial?.diffuse.contents = UIColor.gray;
                let cylinderNode = SCNNode(geometry: cylinderGeometry);
                cylinderNode.position.y = Float(height/2);

                let xAxisNode = SCNNode();
                xAxisNode.eulerAngles.x = Float(-Double.pi / 2);
                xAxisNode.addChildNode(cylinderNode);

                let startNode = SCNNode();
                let endNode = SCNNode();
                startNode.position = startPos;
                endNode.position = endPos;
                startNode.addChildNode(xAxisNode);
                startNode.constraints = [SCNLookAtConstraint(target: endNode)];
                
                if start[0].symbol == "H"{
                    startNode.name = start[0].symbol;
                }
                else if end[0].symbol == "H"{
                    startNode.name = end[0].symbol;
                }
                
                self.scnScene.rootNode.addChildNode(startNode);
            }
        }
        loadingView.stopAnimating();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToLigands"{
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Data.atoms.removeAll();
        Data.links.removeAll();
        initView();
        initScene();
        initCam();
        getPDB(name: self.title ?? "");
    }
}
