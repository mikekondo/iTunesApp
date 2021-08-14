//
//  ViewController.swift
//  ITunesApp
//
//  Created by 近藤米功 on 2021/08/02.
//

import UIKit
import SDWebImage
import AVFoundation
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,MusicProtocol {
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var musicTableView: UITableView!
    var musicModel = MusicModel()
    var player:AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        musicTableView.delegate = self
        musicTableView.dataSource = self
        searchTextField.delegate = self
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //tableViewDelegateによるデリゲートメソッド
    //returnカウントの数だけcellForRowAtが呼ばれる
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicModel.artistNameArray.count
    }
    //tableViewDelegateによるデリゲートメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = musicTableView.dequeueReusableCell(withIdentifier: "musicCell", for: indexPath)
        let artWorkImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let musicNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        let artistNameLabel = cell.contentView.viewWithTag(3) as! UILabel
        //写真、音楽名、アーティスト名の格納
        artWorkImageView.sd_setImage(with: URL(string: musicModel.artworkUrl100Array[indexPath.row]), completed: nil)
        musicNameLabel.text = musicModel.trackCensoredNameArray[indexPath.row]
        artistNameLabel.text = musicModel.artistNameArray[indexPath.row]
        //楽曲再生ボタンの作成
        let musicPlayButton = UIButton(frame: CGRect(x: 35, y: 21, width: 130, height: 130))
        musicPlayButton.setImage(UIImage(named:"play"), for: .normal)
        //ボタンを押したとき
        musicPlayButton.addTarget(self, action: #selector(playButtonTap(_:)), for:.touchUpInside)
        musicPlayButton.tag = indexPath.row
        //セルにmusicButtonを追加(StoryBoardにないから)
        cell.contentView.addSubview(musicPlayButton)
        return cell
    }
    //ボタンをタップした時
    @objc func playButtonTap(_ sender:UIButton){
        //音楽を止める
        if player?.isPlaying == true{
            player?.stop()
        }
        //sender.tagはindexPath.rowすなわちplayButton.tagとい一緒
        let url = URL(string: musicModel.previewUrlArray[sender.tag])
        downLoadMusicURL(url: url!)
    }
    //リターンが押されたときにキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードを閉じる
        refleshData()
        textField.resignFirstResponder()
        return true
    }
    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    //ダウンロードメソッド
    func downLoadMusicURL(url:URL){
      var downloadTask:URLSessionDownloadTask
      downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (url, response, error) in
        self.play(url: url!)
      })
      downloadTask.resume()
    }
    //音楽再生メソッド
    func play(url:URL){
      do {
        player = try AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.volume = 1.0
        player?.play()
      } catch let error as NSError {
        print(error.description)
      }
    }
    //MusicProtocolによるデリゲートメソッド
    func catchData(count: Int) {
        if count == 1{
            musicTableView.reloadData()
        }
    }
    func refleshData(){
        //テキストフィールドの中にアーティスト名が入ってたらアーティスト名を用いてitunesAPIを用いる
        if searchTextField.text?.isEmpty != nil{
            let urlString = "https://itunes.apple.com/search?term=\(String(describing:searchTextField.text!))&entity=song&contry=jp"
            //urlStringをエンコードする
            let encodeUrlString:String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            //委任
            musicModel.musicDelegate = self
            musicModel.setData(resultCount: 50, encodeUrlString: encodeUrlString)
            //キーボードを閉じる
            searchTextField.resignFirstResponder()
        }
    }
    
    @IBAction func searchAction(_ sender: Any) {
        refleshData()
    }
    
}

