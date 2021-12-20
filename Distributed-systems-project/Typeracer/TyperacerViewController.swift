import MultipeerConnectivity
import UIKit

class TyperacerViewController: UIViewController {
    
    var peers: [MCPeerID] = []
    
    private var progress: Float {
        return Float(nextLetterPointer - incorrectCount) / Float(self.text.string.count)
    }
    
    var nextLetterPointer: Int = 0 {
        didSet {
            if nextLetterPointer < 0 {
                nextLetterPointer = 0
            }
        }
    }

    private var incorrectCount = 0 {
        didSet {
            if incorrectCount < 0 {
                incorrectCount = 0
            }
        }
    }
    
    private var text: NSMutableAttributedString = .init(string:
                                                            "Put into practical terms, if you're the only person in the world who owns a cellphone, you can't call anyone. But if another person gets one you can now make one connection, if five people have one then there are 10 possible connections, if 12 people get one then there are 66 possible connections, and so on - the value increases massively as more people join the network."
    )

    var textCount: Int!
    
    lazy var textBar: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: UIFont.Weight(CGFloat(250)))
        label.sizeToFit()
        
        let attributedString: NSMutableAttributedString = text
        label.attributedText = attributedString
//        
        return label
    }()
    
    lazy var inputField: UITextField = {
        let field = UITextField()
        field.text = ""
        field.font = .systemFont(ofSize: 32)
        field.allowsEditingTextAttributes = false
        field.autocorrectionType = UITextAutocorrectionType.no
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        return field
    }()
    
    lazy var progressBar: UIStackView = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: UIFont.Weight(CGFloat(250)))
        label.text =  "You:            "
        
        let progBar = UIProgressView()
        progBar.progress = progress
        
        let stack = UIStackView(arrangedSubviews: [
            label,
            progBar
        ])
        stack.axis = .horizontal
        stack.sizeToFit()
        return stack
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            createProgressBar(name: "", progress: 0),
            createProgressBar(name: "", progress: 0),
            createProgressBar(name: "", progress: 0),
            createProgressBar(name: "", progress: 0),
        ])
        stack.spacing = 15
        stack.axis = .vertical
        stack.alignment = .leading
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        nextLetterPointer = 0
        textCount = text.string.count
        inputField.delegate = self
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
        
        view.addSubview(textBar)
        view.addSubview(inputField)
        view.addSubview(progressBar)
        view.addSubview(stackView)
        applyConstrains()
    }
    
    func createProgressBar(name: String, progress: Float) -> UIStackView {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: UIFont.Weight(CGFloat(250)))
        label.text =  "\(name)"
        
        let progBar = UIProgressView()
        progBar.progress = progress
        progBar.backgroundColor = .white
        progBar.trackTintColor = .white
        let stack = UIStackView(arrangedSubviews: [
            label,
            progBar
        ])
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.3).isActive = true
        progBar.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        stack.axis = .horizontal
        stack.sizeToFit()
//        progBar.translatesAutoresizingMaskIntoConstraints = false
//        progBar.widthAnchor.constraint(equalToConstant: 330).isActive = true
//        progBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return stack
    }
    
    // MARK: - Network
    
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    
    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func startHosting(action: UIAlertAction) {
        guard let mcSession = mcSession else {
            return
        }
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant?.start()
    }

    func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else {
            return
        }
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    // MARK: - Constraints
    
    func applyConstrains() {
        textBar.translatesAutoresizingMaskIntoConstraints = false
        inputField.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 20),
            
            stackView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            textBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            textBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
//            textBar.heightAnchor.constraint(equalToConstant: 450),
            textBar.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 50),
            textBar.bottomAnchor.constraint(equalTo: inputField.topAnchor),
            
            inputField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            inputField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            inputField.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            inputField.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}

extension TyperacerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        (progressBar.arrangedSubviews[1] as? UIProgressView)?.progress = progress
       
        if mcSession.connectedPeers.count > 0 {
            let data = withUnsafeBytes(of: progress) { Data($0) }
            do {
                try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch {
                print("connection failure")
            }
        }

        
        if incorrectCount >= 5, string != "" {
            return false
        }
        if nextLetterPointer > textCount - 1 {
            return false
        }
        
        switch string {
        case "":
            backspacePressed()
            return true
        case " ":
            spacePressed()
            return false
        case String(text.string[nextLetterPointer]):
            if incorrectCount == 0 {
                correctInput()
            } else {
                incorrectInput()
            }
            return true
        default:
            incorrectInput()
            return true
        }
    }
}

extension TyperacerViewController {
    func backspacePressed() {
        guard
            let attributedText = textBar.attributedText,
            let inputText = inputField.text
        else {
            return
        }
        
        if inputText != "" {
            nextLetterPointer -= 1
            incorrectCount -= 1
            let attributedString = NSMutableAttributedString(attributedString: attributedText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: nextLetterPointer, length: 1))
            textBar.attributedText = attributedString
        }
    }
    
    func spacePressed() {
        guard
            let input = inputField.text
        else {
            return
        }
        if !input.isEmpty, incorrectCount == 0, text.string[nextLetterPointer] == " " {
            nextLetterPointer += 1
            inputField.text = ""
        }
    }
    
    func correctInput() {
        guard
            let attributedText = textBar.attributedText
        else {
            return
        }
        nextLetterPointer += 1
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: NSRange(location: 0, length: nextLetterPointer))
        textBar.attributedText = attributedString
    }
    
    func incorrectInput() {
        guard
            let attributedText = textBar.attributedText
        else {
            return
        }
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: nextLetterPointer, length: 1))
        
        incorrectCount += 1
        textBar.attributedText = attributedString
        nextLetterPointer += 1
    }
}

extension String {
    subscript(i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}

extension TyperacerViewController: MCSessionDelegate {
    
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
        let value = data.withUnsafeBytes {
            $0.load(as: Float.self)
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if let index = self.peers.firstIndex(of: peerID) {
                let stack = self.stackView.arrangedSubviews[index] as? UIStackView
                let label = stack?.arrangedSubviews[0] as? UILabel
                label?.text = "\(peerID.displayName)"
                let progress = stack?.arrangedSubviews[1] as? UIProgressView
                progress?.progress = value
            } else {
                self.peers.append(peerID)
                let stack = self.stackView.arrangedSubviews[self.peers.count - 1] as? UIStackView
                let label = stack?.arrangedSubviews[0] as? UILabel
                label?.text = "\(peerID.displayName)"
                let progress = stack?.arrangedSubviews[1] as? UIProgressView
                progress?.progress = value
            }
        }
    }
}

extension TyperacerViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}

