#!/bin/bash

function qwen() {
  local persona="$1"
  local question="$2"

  local prefix="qwen-25-coder-7b" # TODO: move this to sub function?
  local filename="$HOME/convos/${prefix}/${persona,,}.md"

  # Create convos directory if it doesn't exist
  if [ ! -d "$HOME/convos" ]; then
    mkdir -p "$HOME/convos"
  fi

  # Create LLM subdirectory if it doesn't exist
  if [ ! -d "$HOME/convos/${prefix}" ]; then
    mkdir -p "$HOME/convos/${prefix}"
  fi

  # Check if the file exists
  if [ ! -f "$filename" ]; then
    # If the file doesn't exist and a second argument is provided, treat it as the "persona preamble"
    if [ -n "$question" ]; then
      echo -e "# YOUR PERSONA:\n$question\n\n" > "$filename"
    else
      touch "$filename"
    fi
  fi

  # Append the user's question to the file
  if [ -n "$question" ]; then
    echo -e "\n\n## MY QUESTION:\n$question" >> "$filename"
    echo -e "\n\n## YOUR RESPONSE:\n" >> "$filename"

    # Run ollama command with the entire content of the file and pipe output to both stdout and the file
    echo "ollama run qwen2.5-coder:7b < \"$filename\" | tee -a \"$filename\""
    cat $filename
  else
      echo "No question provided. Not running the ollama command."
  fi
}

