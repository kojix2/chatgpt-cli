# ChatGPT Shell

ChatGPT Shell is a command-line interface (CLI) tool for interacting with OpenAI's ChatGPT API. It allows users to communicate with the GPT-3.5 Turbo model, an advanced language generation model, and receive context-based responses. Users can also adjust API parameters, use magic commands to perform various actions within the CLI, fetch content from URLs, and replace specified file contents.

## Features

- Interact with OpenAI's ChatGPT API through a command line interface
- Set API parameters like model name (`gpt-3.5-turbo` by default), temperature, and top_p
- Execute magic commands for various actions (e.g., modifying system message, clearing messages)
- Fetch content from URLs and insert it into the chat
- Replace specified file contents with contents from matching file paths

## Prerequisites

- Crystal programming language installed on your system
- OpenAI API Key set as an environment variable `OPENAI_API_KEY`

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/kojix2/chatgpt-shell.git
   ```
   
2. Change to the directory:

   ```bash
   cd chatgpt-shell
   ```

3. Install dependencies:

   ```bash
   shards install
   ```

4. Build the project with `shards build`:

   ```bash
   shards build --release
   ```

5. Add the compiled binary to your system's `PATH`:

   ```bash
   sudo cp ./bin/chatgpt /usr/local/bin
   ```
   
6. Set your OpenAI API key as an environment variable:

   ```bash
   export OPENAI_API_KEY="your_openai_api_key"
   ```

## Usage

To start using ChatGPT Shell, run the `chatgpt` command in your terminal:

```bash
chatgpt_shell
```

Type a message and press Enter to get a response from GPT-3.5 Turbo.

To exit, type `exit` or `quit`.

### Options

You can set various options when running the `chatgpt` command:

```
Usage: chatgpt [options]
    -m MODEL, --model MODEL              Model name (default: gpt-3.5-turbo)
    -s STR, --system STR                 System message
    -n INT                               How many edits to generate for the input and instruction
    -t Float, --temperature Float        Sampling temperature between 0 and 2 affects randomness of output
    -p Float, --top_p Float              Nucleus sampling considers top_p probability mass for token selection
    -d, --debug                          Debug mode
    -v, --version                        Show version
    -h, --help                           Show help
```

### Magic Commands

Within the CLI, you can use magic commands to perform various actions:

- `%debug`: Toggle debug mode
- `%system`: Show the current system message
- `%system <your_message>`: Set a new system message
- `%clear`: Clear all messages
- `%data`: Show data in JSON format
- `%saveall`: Save all data to a file called `chatgpt.json`
- `%save <filename>`: Save the most recent message to a specified file

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kojix2/chatgpt-shell](https://github.com/kojix2/chatgpt-shell).

## License

This project is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
