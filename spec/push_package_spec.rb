require 'spec_helper'
require 'fileutils'

describe PushPackage do

  let(:iconset_path) { fixture_path 'iconset' }

  let(:website_params) do
    {
      'websiteName' =>  'Push Package Test',
      'websitePushID' =>  'web.com.symmetricinfinity.push_package',
      'allowedDomains' =>  ['http://symmetricinfinity.com/push_package/', 'http://lvh.me'],
      'urlFormatString' =>  'http://symmetricinfinity.com/push_package/?%@=%@',
      'authenticationToken' =>  'nr2o1spn515949r5q54so22o8rq95575',
      'webServiceURL' =>  'https://api.zeropush.com/safari'
    }
  end

  let(:expected_manifest) do
    {
      'icon.iconset/icon_128x128.png' => '28969578f1788252807a7d8205db269cb7699fa8',
      'icon.iconset/icon_128x128@2x.png' => 'dd2bf0e3cb998467b0e5f5ae11675a454ad77601',
      'icon.iconset/icon_16x16.png' => '48e791d0c88b92fae51ffa8363821857210fca01',
      'icon.iconset/icon_16x16@2x.png' => '5a74d295cc09ca5896a4ceb7cac0d030cc85e894',
      'icon.iconset/icon_32x32.png' => '8c71bc22f4cfe12ad98aabe94da6a70fe9f15741',
      'icon.iconset/icon_32x32@2x.png' => '750e080d38efe1c227b2498f73f006007f3da24b',
      'website.json' => '3eaed6475443b895a49e3a1220e547f2be90434a'
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
        PushPackage.new({}, iconset_path, certificate)
      end.must_raise(PushPackage::InvalidParameterError)
    end

    it 'must have a valid iconset' do
      lambda do
        PushPackage.new(website_params, '/tmp', certificate)
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

    let(:push_package) { PushPackage.new(website_params, iconset_path, certificate) }

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

    it 'should return the file handle' do
      file = push_package.save(output_path)
      file.must_be_instance_of File
      File.exists?(file.path).must_equal true
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
      store.add_cert(push_package.p12.certificate)
      p7.verify(
        [push_package.p12.certificate],
         store,
         File.read(tmp_path + '/manifest.json'),
         OpenSSL::PKCS7::DETACHED
      ).must_equal true
    end
  end
end
