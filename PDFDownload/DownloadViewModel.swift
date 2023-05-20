////
////  DownloadViewModel.swift
////  PDFDownload
////
////  Created by Azharuddin 1 on 06/05/23.
////
//
//import SwiftUI
//import Combine
//class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
//    var download : Download
//
//    init(download: Download) {
//        self.download = download
//    }
//
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        let destinationURL = download.destinationURL
//        try? FileManager.default.moveItem(at: location, to: destinationURL)
//
//        download.progress = 1.0
//        download.task = nil
//    }
//
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
//        download.progress = progress
//    }
//}
//
//class Download: ObservableObject, Identifiable {
//    let url: URL
//    var task: URLSessionDownloadTask?
//    var progress: Double?
//    var destinationURL: URL {
//        let documentsDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        return documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
//    }
//
//    init(url: URL) {
//        self.url = url
//    }
//
//    func startDownload(){
//        let request = URLRequest(url: url)
//        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: DownloadDelegate(download: self), delegateQueue: nil)
//        task = session.downloadTask(with: request)
//        task?.resume()
//    }
//}
//
//class DownloadViewModel: ObservableObject {
//    @Published var selectedUrl : URL? = nil
//    @Published var showPdf = false
//    var downloads = [Download]()
//    @Published var selectedDownload : Download?
//    init() {
//        for url in pdfURLs{
//            downloads.append(Download(url: url))
//        }
//    }
//
//    func addDownload(for download : Download) {
//         download.startDownload()
//         self.selectedDownload = download
//    }
//    
//    func handleOpenClick(_ download:Download){
//        let documentsDirectoryURL  =   FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let filePath = documentsDirectoryURL.appendingPathComponent(download.url.lastPathComponent).path
//      
//        self.selectedUrl = URL(filePath: filePath)
//        
//        showPdf.toggle()
//    }
//    
//    func localFilePath(for url: URL) -> URL? {
//        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
//        return documentsPath.appendingPathComponent(url.lastPathComponent)
//    }
//}
//
//
//
//let pdfURLs = [
//        URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!,
//        URL(string: "https://www.tutorialspoint.com/swift/swift_tutorial.pdf")!,
//        URL(string: "https://developer.apple.com/swift/resources/SwiftLanguageGuide.pdf")!
//    ]
