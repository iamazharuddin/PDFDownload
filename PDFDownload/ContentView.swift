//
//  ContentView.swift
//  PDFDownload
//
//  Created by Azharuddin 1 on 06/05/23.
//

import SwiftUI
struct ContentView: View {
    @StateObject var viewModel = DownloadViewModel()
    var body: some View {
        NavigationView {
            List(viewModel.downloads) { download in
                HStack {
                           Text(download.url.lastPathComponent)
                           Spacer()

                           if download.task == nil {
                               if FileManager.default.fileExists(atPath: viewModel.localFilePath(for: download.url)!.path) {
                                   Button("Open") {
                                       viewModel.handleOpenClick(download)
                                   }
                               } else {
                                   Button("Download") {
                                       viewModel.addDownload(for: download)
                                   }
                               }
                           } else {
                               if let progress = download.progress {
                                   ProgressView(value: progress)
                               } else {
                                   Text("Failed")
                                       .foregroundColor(.red)
                               }
                           }
                }.sheet(isPresented: $viewModel.showPdf, content: {
                    PDFView(url: viewModel.selectedUrl! )
                       })
            }
            .navigationBarTitle("Downloads")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
