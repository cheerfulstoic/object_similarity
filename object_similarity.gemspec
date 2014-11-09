lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name     = "object_similarity"
  s.version  = '0.0.1'
  s.required_ruby_version = ">= 1.9.1"

  s.authors  = "Brian Underwood"
  s.email    = 'public@brian-underwood.codes'
  s.homepage = "https://github.com/cheerfulstoic/object_similarity/"
  s.summary = "A ruby library to calculate similarity between ruby objects"
  s.license = 'MIT'
  s.description = <<-EOF
A ruby library to calculate similarity between ruby objects
  EOF

  s.require_path = 'lib'
  s.files = Dir.glob("{bin,lib,config}/**/*") + %w(README.md Gemfile object_similarity.gemspec)


end
