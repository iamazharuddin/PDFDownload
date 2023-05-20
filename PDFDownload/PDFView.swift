//
//  PDFView.swift
//  PDFDownload
//
//  Created by Azharuddin 1 on 06/05/23.
//



import SwiftUI
import PDFKit

struct PDFView1: View {
    @Environment(\.presentationMode) var presentationMode
    let url: URL

    var body: some View {
        NavigationView {
            let pdf = PDFDocument(url: url)!
                let page = pdf.page(at: 0)!
              let width = page.bounds(for: .mediaBox).width
              let height = page.bounds(for: .mediaBox).height
               PDFKitView(document: pdf, currentPage: 1, zoomEnabled: true)
                   .frame(width: width, height: height)
                   .navigationTitle("PDF")
                   .navigationBarItems(trailing:
                                  Button("Close") {
                                      presentationMode.wrappedValue.dismiss()
                                  }
                              )
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument
    let currentPage: Int
    let zoomEnabled: Bool

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.displayDirection = .vertical
        pdfView.displayMode = .singlePage
        pdfView.pageBreakMargins = .zero
        pdfView.backgroundColor = UIColor.white
        pdfView.usePageViewController(true, withViewOptions: [UIPageViewController.OptionsKey.interPageSpacing: 20])
//        pdfView.pageView?.backgroundColor = UIColor.white
        pdfView.isUserInteractionEnabled = true
        pdfView.zoomIn(nil)
        pdfView.goToFirstPage(nil)
        pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.maxScaleFactor = 5
        pdfView.displaysRTL = true
        pdfView.displaysAsBook = false
        pdfView.enableDataDetectors = true
        pdfView.documentView?.backgroundColor = UIColor.white
//        pdfView.currentPage = document.page(at: currentPage)!
//        pdfView.isUserInteractionEnabled = zoomEnabled
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
//        uiView.currentPage = document.page(at: currentPage)!
        uiView.isUserInteractionEnabled = zoomEnabled
    }
    

}
