//
//  CustomView.swift
//  YoutubePlayer
//
//  Created by 김규리 on 2022/02/22.
//

import UIKit
import youtube_ios_player_helper


class CustomView: UIView {
    private var startPlay = false
    private var isPlaying = false
    private var isFull = false
    
    private var videoId:String = ""
    private var isControlled = true
    private var currentTime: Float = 0.0
    private var endTime: Float = 0.0
    
    
    @IBOutlet var playerView: YTPlayerView!
    @IBOutlet var lblCurrentTime: UILabel!
    @IBOutlet var lblEndTime: UILabel!
    @IBOutlet var slProgressPlay: UISlider!
    @IBOutlet var btnFullScreen: UIButton!


    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

extension CustomView { // set, get 함수
    public func setVideoId(videoId: String){
        self.videoId = videoId
    }
    
    public func setIsControlled(isControlled: Bool){
        self.isControlled = isControlled
    }
    
    // 동영상의 현재 재생시간을 업데이트하고 출력해주는 함수
    // 재생시간에 따라 슬라이더 이동
    public func setCurrentTime() {
        playerView.currentTime { [self] time, error in
            guard let err = error else {
                // currentTime에 재생시간 저장
                self.currentTime = Float(time)
                lblCurrentTime.text = convertTime2String(self.currentTime)
                slProgressPlay.value = (currentTime/endTime)
                return
            }
            print("Error :\(err)")
        }
    }
    
    // 동영상의 길이를 저장하고 출력해주는 함수
    public func setEndTime() {
        playerView.duration { [self]time, error in
           guard let err = error else {
               // endTime에 동영상 길이 저장
               self.endTime = Float(time)
               lblEndTime.text = convertTime2String(self.endTime)
               return
           }
            print("Error :\(err)")
        }
    }
    
    public func getVideoId() -> String{
        return videoId
    }
    
    public func getIsControlled() -> Bool{
        return isControlled
    }
    
    public func getEndTime() -> Float{
        return endTime
    }
    
    public func getCurrentTime() -> Float{
        return currentTime
    }
    
    public func getStartPlay() -> Bool{
        return startPlay
    }
    
    public func getIsPlaying() -> Bool{
        return isPlaying
    }
    
    public func getIsFull() -> Bool{
        return isFull
    }
}

extension CustomView { //
    // slProgressPlay 액션함수 : 슬라이더가 움직이면 동영상 이동
    // 동영상 재생이 시작되고, 슬라이더 컨트롤이 가능할 때만 실행
    @IBAction func changeProgress(_ sender: UISlider) {
        if startPlay , isControlled {
            playerView.seek(toSeconds: endTime * slProgressPlay.value, allowSeekAhead: true)
            setCurrentTime()
        }
    }
        
    // btbFullScreen 액션함수 : 버튼 클릭시 전체화면으로 비디오 재생
    @IBAction func fullScreenVideo(_ sender: UIButton) {
        let frame = UIScreen.main.bounds
        let frameHeight = frame.height
        let frameWidth = frame.width

        let playerViewHeight = playerView.frame.size.height
        let playerViewWidth = playerView.frame.size.width
        let playerView_AxisX = playerView.frame.origin.x
        let playerView_AxisY = playerView.frame.origin.y

        let move = CGAffineTransform(translationX: -playerView_AxisX, y: -playerView_AxisY + frameHeight/2 - playerViewHeight/2)
        let scale = CGAffineTransform(scaleX: frameWidth/playerViewWidth * (16/9), y: frameWidth/playerViewHeight)
        let rotate = CGAffineTransform(rotationAngle: .pi/2)
        let combine = scale.concatenating(rotate).concatenating(move)

        if !isFull {
            self.transform = combine
            playerView.transform = combine

            isFull = true
        } else {
            self.transform = CGAffineTransform.identity
            playerView.transform = CGAffineTransform.identity

            isFull = false
        }
    }
    
    // youtube 기본 컨트롤바를 숨기고 유튜브 동영상을 로드해주는 함수
    public func loadVideo() {
        if videoId != "" {
            playerView.load(withVideoId: self.videoId, playerVars: ["controls": 0])
        }
        else {
            print("videoId를 입력하세요.")
        }
    }
    
    // 탭 제스처를 받았을 때 재생상황에 따라 동영상을 처리해주는 함수
    public func doTouch() {
        if !startPlay {
            playerView.playVideo()
            setEndTime()
            startPlay = true
            isPlaying = true
        }
        else {
            if !isPlaying {
                playerView.playVideo()
                isPlaying = true
            } else {
                playerView.pauseVideo()
                isPlaying = false
            }
        }
    }
    
    // float타입의 시간을 string으로 변환하고 리턴해주는 함수
    public func convertTime2String(_ time :Float) -> String {
        let min = Int(time/60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let strTime = String(format: "%02d:%02d", min, sec)
        
        return strTime
    }
    
    // 슬라이더 thumb 이미지를 변경해주는 함수
    public func changeSlThumbImage(color: UIColor, size: Double) {
        let thumbView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        thumbView.layer.cornerRadius = thumbView.frame.height / 2
        thumbView.backgroundColor = color
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        
        let image = renderer.image { context in
            thumbView.layer.render(in: context.cgContext)
        }
        slProgressPlay.setThumbImage(image, for: .normal)
    }

}
