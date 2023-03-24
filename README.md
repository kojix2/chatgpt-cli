# ChatGPT CLI

ChatGPT CLI is a command-line interface tool for interacting with OpenAI's ChatGPT API. Users can communicate with the GPT model, adjust API parameters, use magic commands, insert specified file contents, fetch content from URLs, and execute system commands while chatting.

[![asciicast](https://asciinema.org/a/569659.svg)](https://asciinema.org/a/569659)

## Features

1. Interact with OpenAI's ChatGPT API through a command-line interface
2. Set API parameters like model name (`gpt-3.5-turbo` by default), temperature, and top_p
3. Select pre-registered system messages with ID
4. Execute magic commands for various actions (e.g. modifying the system message, saving message, debugging)
5. Execute system commands while chatting
6. Fetch file contents from paths and insert them into the chat
7. Fetch contents from URLs and insert them into the chat

## Installation

1. Install Crystal

2. Build the project:

   ```bash
   git clone https://github.com/kojix2/chatgpt-cli
   cd chatgpt-cli
   shards install
   shards build --release
   ```

3. Add the compiled binary to your system's `PATH`:

   ```bash
   sudo cp ./bin/chatgpt /usr/local/bin
   ```

4. Set your OpenAI API key as an environment variable:

   ```bash
   export OPENAI_API_KEY="your_openai_api_key"
   ```

## Usage

To start using ChatGPT CLI, run the `chatgpt` command in your terminal:

```bash
chatgpt
```

Type a message and press Enter to get a response from GPT-3.5 Turbo.

To exit, type `exit`, `quit`, or press `Ctrl + D`.

### Options

You can set various options when running the `chatgpt` command:

```
Usage: chatgpt [options]
    -i NAME, --identifier NAME           Custom system message from configuration file
    -m MODEL, --model MODEL              Model name (default: gpt-3.5-turbo)
    -s STR, --system STR                 System message
    -n INT                               How many edits to generate for the input and instruction
    -t Float, --temperature Float        Sampling temperature between 0 and 2 affects randomness of output
    -p Float, --top_p Float              Nucleus sampling considers top_p probability mass for token selection
    -d, --debug                          Debug mode
    -v, --version                        Show version
    -h, --help                           Show help
```

### Select a pre-defined system command

```
chatgpt -i translator
```

To add or remove system commands, see the CONFIGURATION section.

### File Insertion with %{}

You can insert the contents of a file into the chat by enclosing the file path in `%{}`. For example, if you want to insert the contents of a file called `example.py` located in the `src` directory, you can use `%{src/example.py}`.

```
> Please explain what the following code does. Are there any bugs?　%{src/example.py}
```

### Web Page Insertion with %%{} (experimental)

You can insert the contents of a web page.

```
> Please raise five topics from the following pages that you find interesting %%{https://news.ycombinator.com/}
```

Here we get the html from the URL, extract the words used in the `body` and pass them to ChatGPT. It is much smaller than the raw html, but still not enough.

### Magic Commands

Within the CLI, you can use magic commands to perform various actions:

- `%debug`: Toggle debug mode
- `%system`: Show the current system message
- `%system <your_message>`: Set a new system message
- `%clear`: Clear all messages
- `%data`: Edit data in JSON format
- `%save <filename>`: Save the most recent message to a specified file
- `%saveall`: Save all data to a file called `chatgpt.json`
- `%config`: Edit config file
- `%help`: Show the help

### Execuging System Commands

You can execute system commands while chatting by prefixing the command with the `!` symbol. For example, if you want to check the current working directory, you can type `!pwd` and press Enter. Similarly, you can execute other system commands like `!ls`, `!date`, etc.

## Configuration

The system messages used by ChatGPT CLI can be customized through the `config.json` file. The file is located in `~/.config/chatgpt-cli/` by default, but can be changed by setting the `CHATGPT_CLI_CONFIG` environment variable.

The `config.json` file has the following structure:

```json
{
  "system_messages": {
    "translator": {
      "role": "system",
      "content": "I want you to act as an translator, spelling corrector and improver."
    },
    "code": {
      "role": "system",
      "content": "I want you to act as a programmer, writing code."
    },
    "poet": {
      "role": "system",
      "content": "I want you to act as a poet, writing poetry."
    }
  }
}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kojix2/chatgpt-cli](https://github.com/kojix2/chatgpt-cli).

## License

This project is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
