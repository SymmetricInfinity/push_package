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
package = PushPackage.new(website_params, iconset_path, certificate, 'optional cert password')
package.save('path/to/save')

```

```shell
$> push_package --website-json=./website.json --iconset-path=~/project/iconset --output-dir=./ --certificate=./Certificate.p12
   wrote: ./pushPackage.zip
```

## Contributing

1. Fork it
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Write tests for your feature
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create new Pull Request
