# chatgpt command line tool

This tool does not yet have an official name.
To use this tool, an OpenAI Access Token is required.

Please Set `ENV["OPENAI_API_KEY"]`

## Install

```sh
shards
make
sudo make install
```

## Usage

```sh
chatgpt
```

This tool allows you to load files using placeholders.

```
> Please read the code #{chatgpt.cr}
```

## Options

```
Usage: ./chatgpt [options]
    -n INT                           How many edits to generate for the input and instruction.
    -t Float, --temperature Float    Sampling temperature between 0 and 2 affects randomness of output.
    -p Float, --top_p Float          Nucleus sampling considers top_p probability mass for token selection.
    -d, --debug                      Print request data
    -v, --version                    Show version
    -h, --help                       Show help
```

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

[MIT License](https://opensource.org/licenses/MIT).
