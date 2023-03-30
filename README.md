# ChatGPT CLI

[![build](https://github.com/kojix2/chatgpt-cli/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/chatgpt-cli/actions/workflows/build.yml)

ChatGPT CLI is a command-line interface tool for interacting with OpenAI's [ChatGPT API](https://platform.openai.com/docs/api-reference/chat). It allows users to communicate with the GPT model, adjust API parameters, use magic commands, insert file contents, fetch content from URLs, and execute system commands while chatting.

## Features

- Interact with OpenAI's ChatGPT API through a command-line interface
- Set API parameters like model name (`gpt-3.5-turbo` by default), temperature, and top_p
- Select pre-registered system messages with ID
- Execute magic commands for various actions (e.g., modifying the system message, saving messages, debugging)
- Execute system commands while chatting
- Fetch file contents from paths and insert them into the chat
- Fetch contents from URLs and insert them into the chat

## Installation

1. Install [Crystal](https://github.com/crystal-lang/crystal)
2. Build the project:

   ```bash
   git clone https://github.com/kojix2/chatgpt-cli
   cd chatgpt-cli
   make
   sudo make install
   ```

3. Set your OpenAI API key as an environment variable:

   ```bash
   export OPENAI_API_KEY="your_openai_api_key"
   ```

## Usage

To start using ChatGPT CLI, run the `chatgpt` command in your terminal:

```bash
chatgpt
```

Type a message and press Enter to get a response from GPT-3.5 Turbo. To exit, type `exit`, `quit`, or press `Ctrl + D`.

### Options

You can set various options when running the `chatgpt` command:

```
Usage: bin/chatgpt [options]
    -m MODEL, --model MODEL          Model name [gpt-3.5-turbo]
    -i ID, --id ID                   ID of the custom system message
    -s STR, --system STR             System message
    -n INT                           Number of edits to generate [1]
    -t Float, --temperature Float    Sampling temperature to use [1.0]
    -p Float, --top_p Float          Probability threshold of nucleus sampling [1.0]
    -v, --version                    Print version info and exit
    -h, --help                       Print help
```

### Select a pre-defined system command

```bash
chatgpt -i code
```

To add or remove system commands, see the CONFIGURATION section.

### File Insertion with %{}

You can insert the contents of a file into the chat by enclosing the file path in `%{}`. For example, to insert the contents of a file called `example.py` located in the `src` directory, use `%{src/example.py}`.

```
> Please explain what the following code does. Are there any bugs? %{src/example.py}
```

```
> Please read the code of the tool: %{src/**/*} Then update README.md %{README.md}
...
> %w README.md
```

### Web Page Insertion with %%{} (experimental)

You can insert the contents of a web page.

```
> Please choose five interesting topics from %%{https://news.ycombinator.com/}
```

Here the HTML from the URL is fetched, the words used in the `body` are extracted and passed to ChatGPT. It is much smaller than the raw HTML, but still not enough.

### Magic Commands

Within the CLI, you can use magic commands to perform various actions:

- `%clear` : Clear all messages
- `%undo <n>` : Undo last query and response [1]
- `%write <filename>`: Write the most recent message to a specified file
- `%w <filename>`: Alias for `write`
- `%config`: Edit config file
- `%system`: Show the current system message
- `%system <message>`: Set a new system message
- `%resume` : Load data from auto saved data file
- `%edit`: Edit data in JSON format
- `%save <filename>`: Save data to a file [`chatgpt.json`]
- `%load <filename>`: Load data from a file [`chatgpt.json`]
- `%token(s)`: Total tokens used
- `%debug`: Toggle debug mode
- `%help`: Show the help

Note that for `%config`, `%data`, and other commands that launch an editor, the editor used can be set by the `EDITOR` environment variable. The default editor is `vim`.

The tool is under development, and the magic commands are still being improved.

### Executing System Commands

You can execute system commands while chatting by prefixing the command with the `!` symbol. For example, to check the current working directory, type `!pwd` and press Enter. Similarly, you can execute other system commands like `!ls`, `!date`, etc. If you want to execute a command and record its output for later use, you can prefix the command with `!!` instead, then use `%STDOUT` or `%STDERR` to insert the captured output into the chat.

#### Examples:

1. Execute a command, and display the output immediately:

```bash
> !pwd
> !vim
> !htop
```

2. Capture the output of a command for later use:

```bash
> !! git diff
... git diff output ...
> Please write commit message: %STDOUT
```

```bash
> !!wrong_command
> Explain the meaning of this error message: %STDERR
```

#### Execute code blocks captured from markdown in the response

When ChatGPT returns code blocks enclosed with triple backticks, ChatGPT CLI saves these blocks temporarily and assigns them to environment variables named `CODE1`, `CODE2`, ... and so on in sequential order. This allows you to execute the code blocks by referencing the environment variables in a system command. For example, if the response contains Python, Ruby, and Bash code blocks, you can execute them using `$CODE1`, `$CODE2`, and `$CODE3`, respectively.

````md
> Write code to display 1 to 10 in Python and Ruby.
> Python:

```
for i in range(1, 11):
    print(i)
```

Ruby:

```
(1..10).each { |i| puts i }
```

> ! python $CODE1
> ! ruby $CODE2
````

## Configuration

The system messages used by ChatGPT CLI can be customized through the `config.json` file. The file is located in `~/.config/chatgpt-cli/` by default, but it can be changed by setting the `CHATGPT_CLI_CONFIG` environment variable.

The `config.json` file has the following structure:

```json
{
  "system_messages": {
    "tran": {
      "role": "system",
      "content": "I want you to act as a translator, spelling corrector, and improver."
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

## Uninstallation

```sh
rm /usr/local/bin/chatgpt   # Remove the executable
rm -r ~/.config/chatgpt-cli # Remove the config directory
rm ~/.chatgpt_history       # Remove command history
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kojix2/chatgpt-cli](https://github.com/kojix2/chatgpt-cli).

## Development

```bash
git clone https://github.com/kojix2/chatgpt-cli
cd chatgpt-cli
shards install
shards build --release
bin/chatgpt
```

## License

This project is open-source and available under the terms of the [MIT License](https://opensource.org/licenses/MIT).
