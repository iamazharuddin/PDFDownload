//
//  PDFView.swift
//  PDFDownload
//
//  Created by Azharuddin 1 on 06/05/23.
//

import SwiftUI
class PDFViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    let documentController: UIDocumentInteractionController

    init(url: URL) {
        self.documentController = UIDocumentInteractionController(url: url)
        super.init(nibName: nil, bundle: nil)
        self.documentController.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.documentController.presentPreview(animated: true)
    }

    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

struct PDFView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<PDFView>) -> UIViewController {
        return PDFViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<PDFView>) {
        // No update needed
    }
}
