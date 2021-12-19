import MultipeerConnectivity
import UIKit

class StartScreenViewController: UIViewController {
    
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    
    let startButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("START GAME", for: .normal)
        btn.addTarget(self, action: #selector(showConnectionPrompt), for: .touchUpInside)
        return btn
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    override func viewDidLoad() {
        view.addSubview(startButton)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }
    
    func startHosting(action: UIAlertAction) {
        guard let mcSession = mcSession else {
            return
        }
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "kamil-khairullin", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant?.start()
    }
    
    func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else {
            return
        }
        let mcBrowser = MCBrowserViewController(serviceType: "kamil-khairullin", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    private func applyConstraints() {
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor)
        ])
    }
    
    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

extension StartScreenViewController: MCSessionDelegate {
    
    func session(
                _ session: MCSession,
                didReceive stream: InputStream,
                withName streamName: String,
                fromPeer peerID: MCPeerID
    ) {}
    
    func session(
                _ session: MCSession,
                didStartReceivingResourceWithName resourceName: String,
                fromPeer peerID: MCPeerID,
                with progress: Progress
    ) {}
    
    func session(
                _ session: MCSession,
                didFinishReceivingResourceWithName resourceName: String,
                fromPeer peerID: MCPeerID,
                at localURL: URL?,
                withError error: Error?
    ) {}
    
    func session(
                _ session: MCSession,
                peer peerID: MCPeerID,
                didChange state: MCSessionState
    ) {
        switch state {
        case .notConnected:
            print("Not connected \(peerID.displayName)")
        case .connecting:
            print("Connecting \(peerID.displayName)")
        case .connected:
            print("Connected \(peerID.displayName)")
        @unknown default:
            print("Unknown state recieved for \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            guard
                let self = self,
                let prevText = self.label.text
            else { return }
            let newStr = String(decoding: data, as: UTF8.self)
            self.label.text = prevText + newStr
        }
    }
    
    /*
     Upload data
     */
}

extension StartScreenViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}
