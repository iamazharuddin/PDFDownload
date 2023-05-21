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
                HStack {
                    Text(fileURL.lastPathComponent)
                    Spacer()
                    if let progress = downloadManager.downloadProgress[fileURL] {
                        Text("\(progress * 100, specifier: "%.1f")%")
                    } else {
                        Button(action: {
                            downloadManager.startDownload(url: fileURL)
                        }) {
                            Text("Download")
                        }
                    }
                }
            }
        }
    }
}

class DownloadManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    var downloadProgress: [URL: Float] = [:]
    var activeDownloads: [URL: URLSessionDownloadTask] = [:]

    func startDownload(url: URL) {
        guard activeDownloads[url] == nil else {
            return
        }

        let downloadTask = createDownloadTask(url: url)
        downloadProgress[url] = 0.0
        activeDownloads[url] = downloadTask
        downloadTask.resume()
    }

    func createDownloadTask(url: URL) -> URLSessionDownloadTask {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let request = URLRequest(url: url)
        let downloadTask = session.downloadTask(with: request)
        downloadTask.resume()
        return downloadTask
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let originalURL = downloadTask.originalRequest?.url,
            let destinationURL = destinationURL(for: originalURL) else {
            return
        }

        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            DispatchQueue.main.async {
                self.downloadDidFinish(url: originalURL)
            }
        } catch {
            print("Error moving downloaded file: \(error)")
        }

        DispatchQueue.main.async {
            self.activeDownloads[originalURL] = nil
            self.downloadProgress[originalURL] = nil
            self.objectWillChange.send()
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.originalRequest?.url,
            let progress = calculateProgress(totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite) else {
            return
        }

        DispatchQueue.main.async {
            self.downloadProgress[url] = progress
            self.objectWillChange.send()
        }
    }

    func calculateProgress(totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) -> Float? {
        guard totalBytesExpectedToWrite > 0 else {
            return nil
        }

        return Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    }

    func destinationURL(for url: URL) -> URL? {
        let documentsDirectoryURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDirectoryURL?.appendingPathComponent(url.lastPathComponent)
    }

    func downloadDidFinish(url: URL) {
        // Handle download finish logic here
        // For example, you can perform any necessary operations after the download completes
        print("Download finished for URL: \(url)")

        // You can access the downloaded file URL using the destinationURL(for:) method
        if let destinationURL = destinationURL(for: url) {
            print("File downloaded at: \(destinationURL.path)")

            // Perform any further operations with the downloaded file, such as displaying it or processing it
            // For example, you can update the UI to reflect the completion of the download
        }
    }
}

