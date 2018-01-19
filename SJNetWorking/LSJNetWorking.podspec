
Pod::Spec.new do |s|
s.name         = "SJNetWorking"
s.version      = "0.1.0"
s.summary      = "网络框架"
s.description  = "网络框架"
s.homepage     = "https://github.com/songjie1314/LSJNetWorking"
s.license      = "MIT"
s.author             = { "阿杰" => "email@address.com" }
s.platform     = :ios, "5.0"

s.source       = { :git => "https://github.com/songjie1314/LSJNetWorking.git", :tag => s.version }

s.source_files  = "SJNetWorking", "SJNetWorking/SJNetWorking/SJNetFrame/*.{h,m}"
s.dependency 'AFNetworking'
s.dependency 'YYCache'
s.requires_arc = true

end
