require 'push_package/version'
require 'json'
require 'fileutils'
require 'tmpdir'
require 'tempfile'
require 'openssl'
require 'zip'

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

  def save(output_path = nil)

    @working_dir = Dir.mktmpdir('pushPackage')

    if output_path
      output_path = File.expand_path(output_path)
    else
      output_path = Dir.tmpdir + '/pushPackage.zip'
    end

    ## overwrite existing push packages
    File.delete(output_path) if File.exists?(output_path)

    zip = Zip::File.open(output_path, Zip::File::CREATE)

    File.open(@working_dir + '/website.json', 'w+') do |json|
      json.write(JSON.dump(@website_params))
    end

    Dir.mkdir(File.join(@working_dir,'icon.iconset'))
    Dir.glob(@iconset_path + '/*.png').each do |icon|
      FileUtils.cp(icon, @working_dir + '/icon.iconset/')
    end

    File.open(@working_dir + '/manifest.json', 'w+') do |manifest|
      manifest.write(manifest_data)
    end

    File.open(@working_dir + '/signature', 'wb+') do |file|
      file.write(signature.to_der)
    end

    Dir.glob(@working_dir + '/**/*').each do |file|
      next if File.directory?(file)
      zip.add(file.gsub("#{@working_dir}/", ''), file)
    end

    zip.close

    #clean up the temporary directory
    FileUtils.remove_entry_secure(@working_dir)

    #re-open the file for reading
    File.open(output_path, 'r')
  end

  private

    def signature
      #use the certificate to create a pkcs7 detached signature
      OpenSSL::PKCS7::sign(@p12.certificate, @p12.key, manifest_data, [], OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED)
    end

    def manifest_data
      manifest_keys = REQUIRED_ICONSET_FILES.map{|f| 'icon.iconset/' + f }
      manifest_keys << 'website.json'
      manifest_values = manifest_keys.map {|file| Digest::SHA1.file(File.join(@working_dir, file)).hexdigest }
      Hash[manifest_keys.zip(manifest_values)].to_json
    end

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
