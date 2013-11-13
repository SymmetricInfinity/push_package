require 'push_package/version'
require 'json'
require 'tempfile'
require 'fileutils'

class PushPackage
  class InvalidIconsetError < StandardError; end
  class InvalidParameterError < StandardError; end

  REQUIRED_WEBSITE_PARAMS = ["websiteName", "websitePushID", "allowedDomains", "urlFormatString", "authenticationToken", "webServiceURL"]
  REQUIRED_ICONSET_FILES  = ["icon_16x16.png", "icon_16x16@2x.png", "icon_32x32.png", "icon_32x32@2x.png", "icon_128x128.png", "icon_128x128@2x.png" ]

  attr_reader :p12

  def initialize(website_params, iconset_path, certificate, password = nil)
    raise InvalidParameterError unless valid_website_params?(website_params)
    raise InvalidIconsetError unless valid_iconset?(iconset_path)
    raise ArgumentError unless certificate

    @website_params = website_params
    @iconset_path = iconset_path

    if certificate.respond_to?(:read)
      cert_data = certificate.read
      certificate.rewind if certificate.respond_to?(:rewind)
    else
      cert_data = File.read(certificate)
    end
    @p12 = OpenSSL::PKCS12.new(cert_data, password)
  end

  def save(output_path)
    Dir.mktmpdir('pushPackage') do |dir|
      json = File.open(dir + '/website.json', 'w+')
      json.write(JSON.dump(@website_params))
      json.close

      Dir.mkdir(File.join(dir,'icon.iconset'))
      Dir.glob(@iconset_path + '/*.png').each do |icon|
        FileUtils.cp(icon, dir + '/icon.iconset/')
      end

      manifest_keys = REQUIRED_ICONSET_FILES.map{|f| 'icon.iconset/' + f }
      manifest_keys << 'website.json'
      manifest_values = manifest_keys.map {|file| Digest::SHA1.file(File.join(dir, file)).hexdigest }
      manifest_data = Hash[manifest_keys.zip(manifest_values)].to_json
      File.open(dir + '/manifest.json', 'w+') do |manifest|
        manifest.write(manifest_data)
      end

      #use the certificate to create a pkcs7 detached signature
      signature = OpenSSL::PKCS7::sign(@p12.certificate, @p12.key, manifest_data, [], OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED)

      File.open(dir + '/signature', 'wb+') do |file|
        file << signature.to_der
      end

      `pushd #{dir}; zip -r #{output_path} ./; popd`
    end
  end

  private

    def valid_website_params?(params)
      REQUIRED_WEBSITE_PARAMS.all? do |param|
        params.keys.include?(param)
      end
    end

    def valid_iconset?(iconset_path)
      REQUIRED_ICONSET_FILES.all? do |file|
        File.exist?(File.join(iconset_path, file))
      end
    end
end
