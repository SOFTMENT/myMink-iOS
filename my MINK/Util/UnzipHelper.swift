import Foundation
import SSZipArchive

class UnzipHelper {
    static func downloadAndUnzipEPUB(epubURL: URL, completion: @escaping (URL?) -> Void) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let epubName = (epubURL.lastPathComponent as NSString).deletingPathExtension
        let downloadDestination = documentsDirectory.appendingPathComponent(epubURL.lastPathComponent)
        let unzipDirectory = documentsDirectory.appendingPathComponent(epubName)
        
        // Download the EPUB file
        let downloadTask = URLSession.shared.downloadTask(with: epubURL) { location, response, error in
            guard let location = location, error == nil else {
                print("Download error: \(String(describing: error))")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Remove the existing file at the destination if it exists
            if FileManager.default.fileExists(atPath: downloadDestination.path) {
                do {
                    try FileManager.default.removeItem(at: downloadDestination)
                } catch {
                    print("Error removing existing file: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
            }
            
            // Move the downloaded file to the destination
            do {
                try FileManager.default.moveItem(at: location, to: downloadDestination)
                
                // Unzip the EPUB file
                do {
                    try SSZipArchive.unzipFile(atPath: downloadDestination.path, toDestination: unzipDirectory.path, overwrite: true, password: nil)
                    print("EPUB Unzipped successfully.")
                    DispatchQueue.main.async {
                        completion(unzipDirectory)
                    }
                } catch {
                    print("Error unzipping file: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                print("Error moving downloaded file: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        
        downloadTask.resume()
    }
}
