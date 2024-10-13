import UIKit


class BookViewController: UIViewController, UIPageViewControllerDataSource {

    private var pageViewController: UIPageViewController!
    var pages: [(URL, String)] = []
    var epubURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupPageViewController()
        if let epubURL = epubURL {
            self.ProgressHUDShow(text: "Loading Book".localized())
            loadEpubContent(from: epubURL)
        } else {
            print("EPUB URL is not set".localized())
        }
    }

    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(title: "Exit".localized(), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self

        if let initialViewController = viewControllerAtIndex(index: 0) {
            pageViewController.setViewControllers([initialViewController], direction: .forward, animated: true, completion: nil)
        }

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func viewControllerAtIndex(index: Int) -> BookPageViewController? {
        if index >= pages.count {
            return nil
        }

        let bookPageViewController = BookPageViewController()
        bookPageViewController.pageContent = pages[index].1
        bookPageViewController.baseURL = pages[index].0.deletingLastPathComponent()
        bookPageViewController.view.tag = index
        return bookPageViewController
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag
        if index == 0 {
            return nil
        }
        index -= 1
        return viewControllerAtIndex(index: index)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag
        index += 1
        if index == pages.count {
            return nil
        }
        return viewControllerAtIndex(index: index)
    }

    private func loadEpubContent(from url: URL) {
        UnzipHelper.downloadAndUnzipEPUB(epubURL: url) { [weak self] unzipDirectory in
            guard let self = self, let unzipDirectory = unzipDirectory else {
                print("Error unzipping epub")
                self?.ProgressHUDHide()
                return
            }
            print("EPUB Unzip Directory: \(unzipDirectory)")
            let epubParser = EpubParser(epubDirectory: unzipDirectory)
            epubParser.parseEpub { chapterURLs in
                guard let chapterURLs = chapterURLs else {
                    print("Error parsing EPUB")
                    self.ProgressHUDHide()
                    return
                }
                self.loadChapters(from: chapterURLs)
                self.ProgressHUDHide()
            }
        }
    }

    private func loadChapters(from urls: [URL: String]) {
        pages = urls.sorted(by: { $0.key.absoluteString < $1.key.absoluteString }).map { ($0.key, $0.value) }
        displayInitialChapter()
    }

    private func displayInitialChapter() {
        if let initialViewController = viewControllerAtIndex(index: 0) {
            pageViewController.setViewControllers([initialViewController], direction: .forward, animated: true, completion: nil)
        }
    }

   
}
