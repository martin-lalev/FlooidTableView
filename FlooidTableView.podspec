Pod::Spec.new do |s|

s.name         = "FlooidTableView"
s.version      = "1.0.4"
s.summary      = "Table view helper for animating changes and managing sections and cells."
s.description  = "Table view helper for animating changes and managing sections and cells."
s.homepage     = "http://github.com/martin-lalev/FlooidTableView"
s.license      = "MIT"
s.author       = "Martin Lalev"
s.platform     = :ios, "11.0"
s.source       = { :git => "https://github.com/martin-lalev/FlooidTableView.git", :tag => s.version }
s.source_files  = "FlooidTableView", "FlooidTableView/**/*.{swift}"
s.swift_version = '5.0'

end
