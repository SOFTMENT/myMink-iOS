import Foundation
import SWXMLHash

class EpubParser: NSObject, XMLParserDelegate {
    private var manifestItems: [String: String] = [:]
    private var spineItems: [String] = []
    private var currentElement: String = ""
    private var currentAttributes: [String: String] = [:]
    private var opfFilePath: String = ""
    private var unzipDirectory: URL!
    
    init(epubDirectory: URL) {
        self.unzipDirectory = epubDirectory
    }
    
    func parseEpub(completion: @escaping ([URL: String]?) -> Void) {
        let containerXMLPath = unzipDirectory.appendingPathComponent("META-INF/container.xml").path
        print("Container XML Path: \(containerXMLPath)")
        if let containerXMLData = FileManager.default.contents(atPath: containerXMLPath) {
            let xml = XMLHash.parse(containerXMLData)
            if let rootfilePath = xml["container"]["rootfiles"]["rootfile"].element?.attribute(by: "full-path")?.text {
                let opfURL = unzipDirectory.appendingPathComponent(rootfilePath)
                print("OPF File Path: \(opfURL.path)")
                parseOPFFile(opfURL) { chapterURLs in
                    completion(chapterURLs)
                }
            } else {
                print("Root file path not found in container.xml")
                completion(nil)
            }
        } else {
            print("Container XML Data not found")
            completion(nil)
        }
    }
    
    private func parseOPFFile(_ opfURL: URL, completion: @escaping ([URL: String]?) -> Void) {
        if let opfParser = XMLParser(contentsOf: opfURL) {
            opfParser.delegate = self
            opfParser.parse()
            
            var chapterURLs: [URL: String] = [:]
            for spineItem in spineItems {
                if let chapterPath = manifestItems[spineItem] {
                    let chapterFullPath = "OEBPS/\(chapterPath)"
                    let chapterURL = unzipDirectory.appendingPathComponent(chapterFullPath)
                    if let content = try? String(contentsOf: chapterURL) {
                        chapterURLs[chapterURL] = content
                    }
                    print("Chapter Path: \(chapterFullPath)")
                    print("Chapter URL: \(chapterURL.path)")
                }
            }
            completion(chapterURLs)
        } else {
            print("Failed to initialize OPF Parser")
            completion(nil)
        }
    }
    
    // Implement XMLParserDelegate methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if elementName == "itemref", let idref = attributeDict["idref"] {
            spineItems.append(idref)
        } else if elementName == "item", let itemId = attributeDict["id"], let href = attributeDict["href"] {
            manifestItems[itemId] = href
        }
    }
}
