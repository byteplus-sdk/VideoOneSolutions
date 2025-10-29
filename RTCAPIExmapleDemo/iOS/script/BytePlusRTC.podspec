Pod::Spec.new do |s|
    s.name             = 'BytePlusRTC'
    s.version          = '3.60.102.5900'
    s.summary          = 'BytePlusRTC is an realtime communication SDK of IOS.'
    s.homepage         = 'https://www.byteplus.com/en/product/rtc'
    s.license          = { :type => 'MIT'}
    s.author           = { 'bytertc' => 'byteplusrtc@byteplus.com' }
    s.source           = { :http => 'https://lf16-bpsdk.bytepluscdn.com/obj/byteplussdk-sg/BytePlusRTC/3.60.102.5900/BytePlusRTC.zip' }
    s.ios.deployment_target = '11.0'
    s.default_subspec = ['Core', 'RealXBase', 'RTCFFmpeg', 'CVByteNN']
    s.subspec 'Core' do |rtc|
        rtc.vendored_frameworks = 'BytePlusRTC.xcframework'
    end
    s.subspec 'ScreenCapture' do |rtc|
        rtc.vendored_frameworks = 'BytePlusRTCScreenCapturer.xcframework'
    end
    s.subspec 'RTCFFmpeg' do |rtc|
	rtc.vendored_frameworks = 'RTCFFmpeg.xcframework'
    end
    s.subspec 'ByteRTCFFmpegAudioExtension' do |rtc|
	rtc.vendored_frameworks = 'ByteRTCFFmpegAudioExtension.xcframework'
    end
    s.subspec 'CVByteNN' do |rtc|
        rtc.vendored_frameworks = 'bytenn.xcframework'
    end
    s.subspec 'RealX' do |rtc|
	rtc.vendored_frameworks = 'RealX.xcframework'
    end
    s.subspec 'RealXBase' do |rtc|
	rtc.vendored_frameworks = 'RealXBase.xcframework'
    end
end
