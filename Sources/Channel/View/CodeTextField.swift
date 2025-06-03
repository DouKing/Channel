//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/9/4.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)

import UIKit

public class CodeTextField: UITextField, UITextFieldDelegate {
    
    let codeLength: Int
    var characterSize: CGSize
    var characterSpacing: CGFloat
    let textPreprocess: (String) -> String
    let validCharacterSet: CharacterSet
    
    let characterLabels: [CharacterLabel]
    
    public init(
        codeLength: Int,
        characterSize: CGSize,
        characterSpacing: CGFloat,
        validCharacterSet: CharacterSet,
        characterLabelGenerator: () -> CharacterLabel = { CharacterLabel() },
        textPreprocess: @escaping (String) -> String = { $0 }
    ) {
        self.codeLength = codeLength
        self.characterSize = characterSize
        self.characterSpacing = characterSpacing
        self.validCharacterSet = validCharacterSet
        self.textPreprocess = textPreprocess
        self.characterLabels = (0..<codeLength).map { _ in characterLabelGenerator() }
        
        super.init(frame: .zero)
        
        loadSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var layerCornerRadius: CGFloat {
        get { characterLabels.first?.layer.cornerRadius ?? 0 }
        set {
            characterLabels.forEach {
                $0.layer.cornerRadius = newValue
                $0.layer.masksToBounds = true
            }
        }
    }
    
    public override var textColor: UIColor? {
        get { return characterLabels.first?.textColor }
        set { characterLabels.forEach { $0.textColor = newValue } }
    }
    
    public override var backgroundColor: UIColor? {
        get { characterLabels.first?.backgroundColor }
        set { characterLabels.forEach { $0.backgroundColor = newValue } }
    }
    
    public override var delegate: UITextFieldDelegate? {
        get { return super.delegate }
        // swiftlint:disable unused_setter_value
        set { assertionFailure() }
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(
            width: characterSize.width * CGFloat(codeLength) + characterSpacing * CGFloat(codeLength - 1),
            height: characterSize.height
        )
    }
    
    private func loadSubviews() {
        super.textColor = UIColor.clear
        
        clipsToBounds = true
        super.delegate = self
        addTarget(self, action: #selector(updateLabels), for: .editingChanged)
        clearsOnBeginEditing = false
        clearsOnInsertion = false
        keyboardType = .asciiCapableNumberPad
        
        characterLabels.forEach {
            $0.textAlignment = .center
            addSubview($0)
        }
    }
    
    public override func caretRect(for position: UITextPosition) -> CGRect {
        let currentEditingPosition = text?.count ?? 0
        let superRect = super.caretRect(for: position)
        
        guard currentEditingPosition < codeLength else {
            return CGRect(origin: .zero, size: .zero)
        }
        
        let x = (characterSize.width + characterSpacing) * CGFloat(currentEditingPosition) + characterSize.width / 2 - superRect.width / 2
        
        return CGRect(
            x: x,
            y: superRect.minY,
            width: superRect.width,
            height: superRect.height
        )
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let origin = super.textRect(forBounds: bounds)
        return CGRect(
            x: -bounds.width,
            y: 0,
            width: 0,
            height: origin.height
        )
    }
    
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return .zero
    }
    
    public override func borderRect(forBounds bounds: CGRect) -> CGRect {
        return .zero
    }
    
    public override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = text
            .map { $0 as NSString }
            .map { $0.replacingCharacters(in: range, with: string) }
            .map(textPreprocess) ?? ""
        let newTextCharacterSet = CharacterSet(charactersIn: newText)
        let isValidLength = newText.count <= codeLength
        let isUsingValidCharacterSet = validCharacterSet.isSuperset(of: newTextCharacterSet)
        
        if isValidLength, isUsingValidCharacterSet {
            textField.text = newText
            sendActions(for: .editingChanged)
        }
        return false
    }
    
    public override func deleteBackward() {
        super.deleteBackward()
        sendActions(for: .editingChanged)
    }
    
    @objc func updateLabels() {
        let text = self.text ?? ""
        
        var chars = text.map { Optional.some($0) }
        while chars.count < codeLength {
            chars.append(nil)
        }
        
        zip(chars, characterLabels).enumerated().forEach { args in
            let (index, (char, charLabel)) = args
            charLabel.update(
                character: char,
                isFocusingCharacter: index == text.count || (index == text.count - 1 && index == codeLength - 1),
                isEditing: isEditing
            )
        }
    }
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        defer { updateLabels() }
        return super.becomeFirstResponder()
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        defer { updateLabels() }
        return super.resignFirstResponder()
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let paste = #selector(paste(_:))
        
        return action == paste
    }
    
    // 任何调整选择范围的行为都会直接把 insert point 调到最后一次
    public override var selectedTextRange: UITextRange? {
        get { return super.selectedTextRange }
        set { super.selectedTextRange = textRange(from: endOfDocument, to: endOfDocument) }
    }
    
    public override func paste(_ sender: Any?) {
        super.paste(sender)
        updateLabels()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        characterLabels.enumerated().forEach { args in
            let (index, label) = args
            label.frame = CGRect(
                x: (characterSize.width + characterSpacing) * CGFloat(index),
                y: 0,
                width: characterSize.width,
                height: characterSize.height
            )
        }
    }
    
    public class CharacterLabel: UILabel {
        var isEditing = false
        var isFocusingCharacter = false
        
        func update(character: Character?, isFocusingCharacter: Bool, isEditing: Bool) {
            self.text = character.map { String($0) }
            self.isEditing = isEditing
            self.isFocusingCharacter = isFocusingCharacter
        }
    }
}

#endif
