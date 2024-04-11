// Copyright (c) 2022 and onwards The McBopomofo Authors.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

import Cocoa

@objc protocol NonModalAlertWindowControllerDelegate: AnyObject {
    func nonModalAlertWindowControllerDidConfirm(_ controller: NonModalAlertWindowController)
    func nonModalAlertWindowControllerDidCancel(_ controller: NonModalAlertWindowController)
}

class NonModalAlertWindowController: NSWindowController {
    @objc(sharedInstance)
    static let shared = NonModalAlertWindowController(windowNibName: "NonModalAlertWindowController")

    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var contentTextField: NSTextField!
    @IBOutlet weak var confirmButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    weak var delegate: NonModalAlertWindowControllerDelegate?

    @objc func show(title: String, content: String, confirmButtonTitle: String, cancelButtonTitle: String?, cancelAsDefault: Bool, delegate: NonModalAlertWindowControllerDelegate?) {
        if window?.isVisible == true {
            self.delegate?.nonModalAlertWindowControllerDidCancel(self)
        }

        self.delegate = delegate

        confirmButton.title = confirmButtonTitle
        if let cancelButtonTitle = cancelButtonTitle {
            cancelButton.title = cancelButtonTitle
            cancelButton.isHidden = false
        } else {
            cancelButton.isHidden = true
        }

        cancelButton.nextKeyView = confirmButton
        confirmButton.nextKeyView = cancelButton

        if cancelButtonTitle != nil {
            if cancelAsDefault {
                window?.defaultButtonCell = cancelButton.cell as? NSButtonCell
            } else {
                cancelButton.keyEquivalent = " "
                window?.defaultButtonCell = confirmButton.cell as? NSButtonCell
            }
        } else {
            window?.defaultButtonCell = confirmButton.cell as? NSButtonCell
        }

        titleTextField.stringValue = title

        let oldContentFrame = contentTextField.frame
        contentTextField.stringValue = content

        var infiniteHeightFrame = oldContentFrame
        infiniteHeightFrame.size.width -= 4.0
        infiniteHeightFrame.size.height = 10240
        var newContentFrame = (content as NSString).boundingRect(
            with: infiniteHeightFrame.size, options: [.usesLineFragmentOrigin],
            attributes: [.font: contentTextField.font!])
        newContentFrame.size.width = max(newContentFrame.size.width, oldContentFrame.size.width)
        newContentFrame.size.height += 4.0
        newContentFrame.origin = oldContentFrame.origin
        newContentFrame.origin.y -= (newContentFrame.size.height - oldContentFrame.size.height)
        contentTextField.frame = newContentFrame

        var windowFrame = window?.frame ?? NSRect.zero
        windowFrame.size.height += (newContentFrame.size.height - oldContentFrame.size.height)
        window?.level = NSWindow.Level(Int(CGShieldingWindowLevel()) + 1)
        window?.setFrame(windowFrame, display: true)
        window?.center()
        window?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction func confirmButtonAction(_ sender: Any) {
        delegate?.nonModalAlertWindowControllerDidConfirm(self)
        window?.orderOut(self)
    }

    @IBAction func cancelButtonAction(_ sender: Any) {
        cancel(sender)
    }

    func cancel(_ sender: Any) {
        delegate?.nonModalAlertWindowControllerDidCancel(self)
        delegate = nil
        window?.orderOut(self)
    }

}
