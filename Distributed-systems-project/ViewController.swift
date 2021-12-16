import MultipeerConnectivity
import UIKit

class ViewController: UIViewController {
    enum InputType {
        case correct
        case incorrect
        case backspace
    }
    
    var nextLetterPointer: Int = 0 {
        didSet {
            if nextLetterPointer < 0 {
                nextLetterPointer = 0
            }
        }
    }

    private var incorrectRange = 0 {
        didSet {
            if incorrectRange < 0 {
                incorrectRange = 0
            }
        }
    }
    
    private var text: NSMutableAttributedString = .init(string: "Put into practical terms, if you’re the only person in the world who owns a cellphone, you can’t call anyone. But if another person gets one you can now make one connection, if five people have one then there are 10 possible connections, if 12 people get one then there are 66 possible connections, and so on – the value increases massively as more people join the network.")
    
    lazy var textBar: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 24, weight: UIFont.Weight(CGFloat(250)))
        label.sizeToFit()
        
        let attributedString: NSMutableAttributedString = text
        label.attributedText = attributedString
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputField.delegate = self
        view.addSubview(textBar)
        view.addSubview(inputField)
        applyConstrains()
        nextLetterPointer = 0
    }
    
    func applyConstrains() {
        textBar.translatesAutoresizingMaskIntoConstraints = false
        inputField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            textBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            textBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            textBar.heightAnchor.constraint(equalToConstant: 500),
            
            inputField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            inputField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            inputField.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            inputField.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch string {
        case "":
            backspacePressed()
            return true
        case " ":
            spacePressed()
            return false
        case String(text.string[nextLetterPointer]):
            if incorrectRange == 0 {
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

extension ViewController {
    func backspacePressed() {
        guard
            let attributedText = textBar.attributedText,
            let inputText = inputField.text
        else {
            return
        }
        
        if inputText != "" {
            nextLetterPointer -= 1
            incorrectRange -= 1
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
        if !input.isEmpty {
            if incorrectRange == 0 {
                nextLetterPointer += 1
                inputField.text = ""
            }
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
        
        incorrectRange += 1
        textBar.attributedText = attributedString
        nextLetterPointer += 1
    }
}

extension String {
    subscript(i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}

