require 'spec_helper'
require 'fileutils'

describe PushPackage do

  let(:iconset_path) { fixture_path 'iconset' }

  let(:website_params) do
    {
      'websiteName' => 'Push Package Test',
      'websitePushID' => 'web.com.symmetricinfinity.push_package',
      'allowedDomains' => ['http://symmetricinfinity.com/push_package/', 'http://lvh.me'],
      'urlFormatString' => 'http://symmetricinfinity.com/push_package/?%@=%@',
      'authenticationToken' => 'nr2o1spn515949r5q54so22o8rq95575',
      'webServiceURL' => 'https://api.zeropush.com/safari'
    }
  end

  let(:website_params_symbol_keys) do
    {
      websiteName: 'Push Package Test',
      websitePushID: 'web.com.symmetricinfinity.push_package',
      allowedDomains: ['http://symmetricinfinity.com/push_package/', 'http://lvh.me'],
      urlFormatString: 'http://symmetricinfinity.com/push_package/?%@=%@',
      authenticationToken: 'nr2o1spn515949r5q54so22o8rq95575',
      webServiceURL: 'https://api.zeropush.com/safari'
    }
  end

  let(:expected_manifest) do
    {
      "icon.iconset/icon_128x128.png" => {"hashType"=>"sha512", "hashValue"=>"2a3057b4783df18ddb501adf03241ee6d32e5d3ae1eef3b1bc67f68a40ca2f9c4c3851b5c4473628964b8097e3c8aa6a0a552b78e39200bed0e3a6f9ad5245d8"},
      "icon.iconset/icon_128x128@2x.png" => {"hashType"=>"sha512", "hashValue"=>"2f18bb895a031c40ff731296656c3544c9631074f4b34fb537ebda765e5a993cadf2e3f1c4245480a7403b7f00d8a0af73631a90e8f9b1efc18bd0e3f0773490"},
      "icon.iconset/icon_16x16.png" => {"hashType"=>"sha512", "hashValue"=>"80cb914ccb155986b1306586f0779d251f4798605f1fc7ff79355b34bded1e55676c62553ebce51e1f2df82cac6fd138828106868bbdc6f631bc6b32e9ea3817"},
      "icon.iconset/icon_16x16@2x.png" => {"hashType"=>"sha512", "hashValue"=>"39737919fdfa0375272e9c173a240fd3f68a8fe7798946dd379a83e76aed1b7f0d92b087497f85e50f5836b03062ecb47b00f7c53d4c0b466da068a559d432b7"},
      "icon.iconset/icon_32x32.png" => {"hashType"=>"sha512", "hashValue"=>"b4a48df25c8fe5881e356112e3aa22a8df8ed180a827bb85330cb73f2d9abc283630622efa4a5135dd84dc6bda2eefe2aa79bfb67a954a0cd0e45a5de58e0de1"},
      "icon.iconset/icon_32x32@2x.png" => {"hashType"=>"sha512", "hashValue"=>"3dcad42ae5729b1aefb07f3dc0c501c32027a8482d5424648e67fe484fcdc0be60d69ed97915c2b4a08e286990f2ecc88c2603bb79f9a523cb448906c19eeee9"},
      "website.json" => {"hashType"=>"sha512", "hashValue"=>"a9fe3fcc467aa08ad7871f6ddb399453c2d2f00890ba6177633c36dabcb9313d46f69a54679ca41a404ebc89e2532bbff088ee9a6e649c2b3d33b44d3d78ebfb"}
    }
  end

  let(:certificate) { File.open(fixture_path('self-signed.p12')) }

  describe 'the truth' do
    it 'should pass' do
      'test'.must_equal('test')
    end
  end

  describe '.new' do
    it 'should check website_params' do
      lambda do
        PushPackage.new({}, iconset_path, certificate, 'testing')
      end.must_raise(PushPackage::InvalidParameterError)
    end

    describe 'website params with string keys' do

      it 'must have a valid iconset' do
        lambda do
          PushPackage.new(website_params, '/tmp', certificate, 'testing')
        end.must_raise(PushPackage::InvalidIconsetError)
      end

      it 'should support a certificate path' do
        lambda do
          PushPackage.new(website_params, iconset_path, nil)
        end.must_raise(ArgumentError)
      end

      it 'should support certificate path' do
        lambda do
          PushPackage.new(website_params, iconset_path, '/some/file.p12')
        end.must_raise(Errno::ENOENT)
      end

      it 'should support intermediate_cert path' do
        lambda do
          PushPackage.new(website_params, iconset_path, certificate, 'testing', '/some/file.crt')
        end.must_raise(Errno::ENOENT)
      end
    end

    describe 'website params with string keys' do
      it 'must have a valid iconset' do
        lambda do
          PushPackage.new(website_params_symbol_keys, '/tmp', certificate, 'testing')
        end.must_raise(PushPackage::InvalidIconsetError)
      end

      it 'should support a certificate path' do
        lambda do
          PushPackage.new(website_params_symbol_keys, iconset_path, nil)
        end.must_raise(ArgumentError)
      end

      it 'should support certificate path' do
        lambda do
          PushPackage.new(website_params_symbol_keys, iconset_path, '/some/file.p12')
        end.must_raise(Errno::ENOENT)
      end

      it 'should support intermediate_cert path' do
        lambda do
          PushPackage.new(website_params_symbol_keys, iconset_path, certificate, 'testing', '/some/file.crt')
        end.must_raise(Errno::ENOENT)
      end
    end
  end

  describe '#save' do
    let(:output_path) { '/tmp/pushPackage.zip' }
    let(:tmp_path) { '/tmp/pushPackage' }
    let(:extracted_package) do
      `unzip #{output_path} -d #{tmp_path}`
      Dir.glob(tmp_path + '/**/*').map do |d|
        d.gsub(tmp_path + '/', '')
      end
    end

    let(:push_package) { PushPackage.new(website_params, iconset_path, certificate, 'testing') }

    before do
      push_package.save(output_path)
    end

    after do
      File.delete(output_path) if File.exist?(output_path)
      FileUtils.rm_rf(tmp_path)
    end

    it 'should save to the file system' do
      File.exist?(output_path).must_equal true
    end

    it 'should save with a relative path' do
      push_package.save('pushPackage.zip')
      File.exist?('./pushPackage.zip').must_equal true
      File.delete('./pushPackage.zip')
    end

    it 'should save to a temporary path' do
      file = push_package.save
      File.exist?(file.path).must_equal true
      File.delete(file.path)
    end

    it 'supports using a Pathname for iconset_path' do
      iconset_pathname = Pathname.new(iconset_path)
      push_package = PushPackage.new(website_params, iconset_pathname, certificate, 'testing')
      file = push_package.save
      File.exist?(file.path).must_equal true
      File.delete(file.path)
    end

    it 'should return the file handle' do
      file = push_package.save(output_path)
      file.must_be_instance_of File
      File.exist?(file.path).must_equal true
    end

    it 'should be a zip file' do
      extracted_package.wont_be_empty
      $?.success?.must_equal true
    end

    it 'should have a valid manifest.json file' do
      extracted_package.must_include('manifest.json')
      manifest = JSON.load(File.open(tmp_path + '/manifest.json', 'r'))
      manifest.sort.must_equal(expected_manifest.sort)
    end

    it 'should have the iconset in icon.iconset subdirectory' do
      icons = extracted_package.select {|file| file.start_with?('icon.iconset/') }
      icons = icons.map {|i| i.gsub('icon.iconset/', '') }
      icons.sort.must_equal(PushPackage::REQUIRED_ICONSET_FILES.sort)
    end

    it 'should have a website.json file' do
      extracted_package.must_include('website.json')
    end

    it 'should have a valid signature' do
      extracted_package.must_include('signature')
      signature = File.read(tmp_path + '/signature')
      p7 = OpenSSL::PKCS7.new(signature)
      store = OpenSSL::X509::Store.new
      store.add_cert(push_package.certificate)
      p7.verify(
        [push_package.certificate],
         store,
         File.read(tmp_path + '/manifest.json'),
         OpenSSL::PKCS7::DETACHED
      ).must_equal true
    end

    describe 'when using a pem file' do
      let(:certificate) { File.open(fixture_path('self-signed.pem')) }

      it 'should have a valid signature' do
        extracted_package.must_include('signature')
        signature = File.read(tmp_path + '/signature')
        p7 = OpenSSL::PKCS7.new(signature)
        store = OpenSSL::X509::Store.new
        store.add_cert(push_package.certificate)
        p7.verify(
          [push_package.certificate],
          store,
          File.read(tmp_path + '/manifest.json'),
          OpenSSL::PKCS7::DETACHED
        ).must_equal true
      end
    end

    it 'should have no extra certs in signature' do
      extracted_package.must_include('signature')
      signature = File.read(tmp_path + '/signature')
      p7 = OpenSSL::PKCS7.new(signature)
      p7.certificates().size.must_equal 1
    end

    describe 'when intermediate_cert given' do
      describe 'when intermediate_cert is a string' do
        let(:intermediate_cert) { fixture_path('intermediate.crt') }
        let(:push_package) { PushPackage.new(website_params, iconset_path, certificate, 'testing', intermediate_cert) }

        it 'should have one extra cert in signature' do
          extracted_package.must_include('signature')
          signature = File.read(tmp_path + '/signature')
          p7 = OpenSSL::PKCS7.new(signature)
          p7.certificates().size.must_equal 2
        end
      end
      describe 'when intermediate_cert is a Pathname' do
        let(:intermediate_cert) { Pathname.new(fixture_path('intermediate.crt')) }
        let(:push_package) { PushPackage.new(website_params, iconset_path, certificate, 'testing', intermediate_cert) }

        it 'should have one extra cert in signature' do
          extracted_package.must_include('signature')
          signature = File.read(tmp_path + '/signature')
          p7 = OpenSSL::PKCS7.new(signature)
          p7.certificates().size.must_equal 2
        end
      end
    end
  end
end
