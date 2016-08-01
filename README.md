# Push Package

Build Status: [![Build Status](https://travis-ci.org/SymmetricInfinity/push_package.png?branch=master)](https://travis-ci.org/SymmetricInfinity/push_package)

## Purpose

This gem provides a Ruby library and command line tool for creating a push package to be used for [Safari Push Notifications](https://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/NotificationProgrammingGuideForWebsites/PushNotifications/PushNotifications.html#//apple_ref/doc/uid/TP40013225-CH3-SW24).

## Features

* Validates push package contents
* Generates manifest.json
* Signs package with required signature
* Creates pushPackage.zip

## Installation

```gem install push_package```

## Notes:

You must obtain a Website Push certificate from apple which requires a iOS developer license or a Mac developer license

[Starting February 2016](https://developer.apple.com/support/certificates/expiration/), you will also need a copy of the
Apple intermediate cert ([WWDR Certificate, expiring 02/07/23](https://developer.apple.com/certificationauthority/AppleWWDRCA.cer))

```ruby
require 'push_package'

website_params = {
  websiteName: "Bay Airlines",
  websitePushID: "web.com.example.domain",
  allowedDomains: ["http://domain.example.com"],
  urlFormatString: "http://domain.example.com/%@/?flight=%@",
  authenticationToken: "19f8d7a6e9fb8a7f6d9330dabe",
  webServiceURL: "https://example.com/push"
}

iconset_path = 'path/to/iconset'
certificate = 'path/to/certificate.p12' # or certificate_string
intermediate_cert = 'path/to/AppleWWDRCA.cer'
package = PushPackage.new(website_params, iconset_path, certificate, 'optional cert password', intermediate_cert)
package.save('path/to/save')

```

```shell
$> push_package --website-json=./website.json --iconset-path=/path/to/project/iconset --output-dir=./ --certificate=./Certificate.p12
   wrote: ./pushPackage.zip
```

## Development/Test Certificates

```shell
# verify the localhost.crt
openssl verify spec/fixtures/localhost.crt

# verify the localhost.csr
openssl req -text -noout -verify -in spec/fixtures/localhost.csr

# verify the localhost.key
openssl rsa -in spec/fixtures/localhost.key -check -noout

# print information about the certificate to STDOUT
openssl x509 -in spec/fixtures/localhost.crt -text -noout

# generate a new rsa key
openssl genrsa -out spec/fixtures/localhost.key 2048

# generate a new csr from using an existing key
openssl req -new -sha256 -key spec/fixtures/localhost.key -out spec/fixtures/localhost.csr

# generate a new certificate using an existing csr and private key
openssl x509 -req -days 3650 -in spec/fixtures/localhost.csr -signkey spec/fixtures/localhost.key -out spec/fixtures/localhost.crt

# export the certificate as a p12
# make sure to set the passphrase to 'testing' because the specs depend on it
openssl pkcs12 -export -out spec/fixtures/self-signed.p12 -inkey spec/fixtures/localhost.key -in spec/fixtures/localhost.crt

```

## Contributing

1. Fork it
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Write tests for your feature
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create new Pull Request
