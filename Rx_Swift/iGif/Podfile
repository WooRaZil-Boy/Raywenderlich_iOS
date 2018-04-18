use_frameworks!

def my_pods
  pod 'RxSwift', '4.0.0'
  pod 'SwiftyJSON'
  # Referencing a specific commit to avoid a problem in 2.0.1. See: https://github.com/kaishin/Gifu/issues/117
  pod 'Gifu', git: 'https://github.com/kaishin/Gifu.git', commit: '693dbc9'
end

target 'iGif' do
  my_pods
end

target 'iGifTests' do
  my_pods
  pod 'Nimble'
  pod 'RxNimble'
  pod 'RxBlocking'
  pod 'OHHTTPStubs'
  pod 'OHHTTPStubs/Swift'
end
