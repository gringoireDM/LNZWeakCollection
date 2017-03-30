Pod::Spec.new do |s|

    s.platform = :ios
    s.version = "1.0.0"
    s.ios.deployment_target = '8.0'
    s.name = "LNZWeakCollection"
 	s.summary      = "A swift collection to store weak references to objects."

  	s.description  = <<-DESC
                   LNZWeakCollection is a collection of weak references to objects. It accepts protocols as type specializer and cleanups itself when a weak reference becomes nil.
                   Useful for implementations of multiple observer in delegate patterns.
                   DESC
                   
    s.requires_arc = true

    s.license = { :type => "MIT" }
	s.homepage = "https://www.pfrpg.net"
    s.author = { "Giuseppe Lanza" => "gringoire986@gmail.com" }

    s.source = {
        :git => "https://github.com/gringoireDM/LNZWeakCollection.git",
        :tag => "v1.0.0"
    }

    s.framework = "Foundation"

    s.source_files = "LNZWeakCollection/**/*.{swift, h}"
end