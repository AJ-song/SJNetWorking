Pod::Spec.new do |s|


  s.name         = "SJNetWorking"
  s.version      = "0.1.5"
  s.summary      = "简单的网络框架"

  s.description  = <<-DESC
                基于AFNetworking 3.x 最新版本的封装，集成了get/post 方法请求数据，单图/多图上传，视频上传/下载，网络监测 等多种网络请求方式 网络请求错误的时候,假如请求设置了缓存, 就可以返回缓存数据,并返回错误信息
                DESC

  s.homepage     = "https://github.com/songjie1314/SJNetWorking"

  s.license      = "MIT"

  s.author       = { "阿杰" => "email@address.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/songjie1314/SJNetWorking.git", :tag => s.version }

  s.source_files  = "SJNetWorking/SJNetFrame/*.{h,m}"

  s.dependency "AFNetworking"
  s.dependency "YYCache"

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
