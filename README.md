## Purpose
Make implementing safari push notifications easier for ruby developers.

## Notes:

```ruby
def create
  package = PushPackage.new(website_params, iconset_path, certificate)
  package.save('path/to/save')
  send_file 'path/to/save'
end
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
