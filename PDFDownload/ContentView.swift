//
//  ContentView.swift
//  PDFDownload
//
//  Created by Azharuddin 1 on 06/05/23.
//


import SwiftUI
struct ContentView: View {
    @ObservedObject var downloadManager = DownloadManager()

    let pdfFiles = [
        URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!,
        URL(string: "https://www.tutorialspoint.com/swift/swift_tutorial.pdf")!,
        URL(string: "https://developer.apple.com/swift/resources/SwiftLanguageGuide.pdf")!
    ]

    var body: some View {
        VStack {
            ForEach(pdfFiles, id: \.self) { fileURL in
                VStack{
                    HStack {
                        Text(fileURL.lastPathComponent)
                        Spacer()
                        if (downloadManager.isFileExists(for: fileURL)){
                            Button(action: {
                            }) {
                                Text("Open")
                            }
                        }else{
                            Button(action: {
                                downloadManager.startDownload(url: fileURL)
                            }) {
                                Text("Download")
                            }
                        }
                    }
                    if  downloadManager.map[fileURL] != nil{
                        ProgressView("Downloading", value: min(downloadManager.map[fileURL]!.progress, 1.0), total: 1.0)
                    }
                }
            }
            Button(action: {
                downloadManager.deleteDownloadedFiles()
            }) {
                Text("Delete")
            }
        }
    }
}

class DownloadManager: ObservableObject {
    @Published var map = [URL:Download]()

    func startDownload(url: URL) {
        let download = Download(url: url)
        download.delegate = self
        download.startDownload()
        map[url] = download
    }
    
    func isFileExists(for url : URL) -> Bool{
        let path = localFilePath(for: url)!.path
        print(path)
        return  FileManager.default.fileExists(atPath: path)
    }
    
    func localFilePath(for url: URL) -> URL? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    func deleteDownloadedFiles() {
            let fileManager = FileManager.default
            let documentsDirectoryURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            do {
                let files = try fileManager.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: nil)
                for file in files {
                    try fileManager.removeItem(at: file)
                }
                map = [URL:Download]()
            } catch {
                print("Error deleting files: \(error)")
            }
        
  
        }
    
//    func handleOpenClick(_ download:Download){
//        let documentsDirectoryURL  =   FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let filePath = documentsDirectoryURL.appendingPathComponent(download.url.lastPathComponent).path
//
//        self.selectedUrl = URL(filePath: filePath)
//
//        showPdf.toggle()
//    }
}

extension DownloadManager: DownloadDelegate {
    func downloadDidFinish(download: Download) {
        DispatchQueue.main.async {
            var clonedMap = self.map
            if let download = clonedMap[download.url]{
                download.progress = 0.0
                clonedMap[download.url] = download
            }
            self.map = clonedMap
        }
    }

    func downloadProgressUpdated(download: Download, progress: Float) {
        DispatchQueue.main.async {
            var clonedMap = self.map
            if let download = clonedMap[download.url]{
                download.progress = progress
                clonedMap[download.url] = download
            }
            self.map = clonedMap
        }
    }
}

protocol DownloadDelegate: AnyObject {
    func downloadDidFinish(download: Download)
    func downloadProgressUpdated(download: Download, progress: Float)
}

class Download  : NSObject, ObservableObject{
    let url: URL
    weak var delegate: DownloadDelegate?
    var task: URLSessionDownloadTask?
    @Published var progress: Float = 0.0
    var destinationURL: URL {
        let documentsDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
    }

    init(url: URL) {
        self.url = url
    }

    func startDownload() {
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        task = session.downloadTask(with: request)
        task?.resume()
    }
}

extension Download: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let delegate = delegate else {
            return
        }

        let destinationURL = self.destinationURL

        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            delegate.downloadDidFinish(download: self)
        } catch {
            print("Error moving downloaded file: \(error)")
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        self.progress = progress

        DispatchQueue.main.async {
            self.delegate?.downloadProgressUpdated(download: self, progress: progress)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
