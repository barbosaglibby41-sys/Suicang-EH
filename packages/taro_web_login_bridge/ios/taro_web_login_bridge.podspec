Pod::Spec.new do |s|
  s.name             = 'taro_web_login_bridge'
  s.version          = '0.1.0'
  s.summary          = 'Native WebView cookie bridge for TaroEH.'
  s.description      = 'Captures authenticated E-Hentai cookies from WKHTTPCookieStore.'
  s.homepage         = 'https://github.com/barbosaglibby41-sys/TaroEH'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'TaroEH' => 'noreply@example.invalid' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.swift_version = '5.0'
end
