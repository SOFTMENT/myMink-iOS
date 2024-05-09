// Copyright © 2023 SOFTMENT. All rights reserved.

protocol SpeedPickerViewControllerDelegate {
    func speedPicker(viewController: SpeedPickerViewController, didChoose speed: SPTAppRemotePodcastPlaybackSpeed)
    func speedPickerDidCancel(viewController: SpeedPickerViewController)
}

class SpeedPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var delegate: SpeedPickerViewControllerDelegate?
    private let podcastSpeeds: [SPTAppRemotePodcastPlaybackSpeed]
    private var selectedSpeed: SPTAppRemotePodcastPlaybackSpeed
    private var selectedIndex: Int = 0
    private let cellIdentifier = "SpeedCell"

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        return tableView
    }()

    init(podcastSpeeds: [SPTAppRemotePodcastPlaybackSpeed], selectedSpeed: SPTAppRemotePodcastPlaybackSpeed) {
        self.podcastSpeeds = podcastSpeeds
        self.selectedSpeed = selectedSpeed
        super.init(nibName: nil, bundle: nil)
        self.updateSelectedindex()
        view.addSubview(self.tableView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Podcast Playback Speed"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .done,
            target: self,
            action: #selector(self.didPressCancel)
        )
    }

    private func updateSelectedindex() {
        let values = self.podcastSpeeds.map { $0.value }
        self.selectedIndex = values.distance(
            from: values.startIndex,
            to: values.firstIndex(of: self.selectedSpeed.value)!
        )
    }

    @objc func didPressCancel() {
        self.delegate?.speedPickerDidCancel(viewController: self)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.speedPicker(viewController: self, didChoose: self.podcastSpeeds[indexPath.row])
        self.selectedSpeed = self.podcastSpeeds[indexPath.row]
        self.selectedIndex = indexPath.row
        tableView.reloadData()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.podcastSpeeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        cell.textLabel?.text = String(format: "%.1fx", self.podcastSpeeds[indexPath.row].value.floatValue)
        if indexPath.row == self.selectedIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}
