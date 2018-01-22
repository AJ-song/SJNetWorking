
Pod::Spec.new do |s|


  s.name         = "SJNetWorking"
  s.version      = "0.1.3"
  s.summary      = "简单的网络框架"

  s.description  = <<-DESC
                       网络错误的时候,假如请求设置了缓存, 就可以返回缓存数据
                   DESC

  s.homepage     = "https://github.com/songjie1314/SJNetWorking"

  s.license      = "MIT"

  s.author             = { "阿杰" => "email@address.com" }
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/songjie1314/SJNetWorking.git", :tag => s.version }

  s.source_files  = "SJNetWorking", "SJNetFrame/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.requires_arc = true

  s.dependency "AFNetworking", "~> 3.1.0"
  s.dependency "YYCache", "~> 1.0.4"

end
