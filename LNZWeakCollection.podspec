Pod::Spec.new do |s|

    s.platform = :ios
    s.version = "1.3.2"
    s.ios.deployment_target = '8.0'
    s.swift_version = '5.0'
    s.name = "LNZWeakCollection"
 	s.summary      = "A swift collection to store weak references to objects."

  	s.description  = <<-DESC
                   LNZWeakCollection has implementations for collections of weak references to objects and dictionary with weak keys or weak values.
                   DESC
                   
    s.requires_arc = true

    s.license = { :type => "MIT" }
	s.homepage = "https://www.pfrpg.net"
    s.author = { "Giuseppe Lanza" => "gringoire986@gmail.com" }

    s.source = {
        :git => "https://github.com/gringoireDM/LNZWeakCollection.git",
        :tag => "v1.3.2"
    }

    s.framework = "Foundation"

    s.source_files = "LNZWeakCollection/**/*.{swift, h}"
end
