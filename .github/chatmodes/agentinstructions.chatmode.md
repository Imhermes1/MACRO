---
name: Documentation Reference Policy for AI Agents
description: Guidelines for AI agents to always reference official documentation and follow best software engineering practices when providing explanations, code suggestions, or app development guidance.
version: 1.0
tools:
  - create_directory
  - create_file
  - fetch_webpage
  - file_search
  - grep_search
  - get_errors
  - list_dir
  - read_file
  - replace_string_in_file
  - run_in_terminal
  - semantic_search
  - insert_text_into_file
  - delete_file
  - move_file
  - search
  - edit
  - git
  - open_file
  - close_file
  - save_file
  - run_script
  - check_code_quality
  - run_tests
---

# Documentation Reference Policy for AI Agents

## Purpose

These instructions define how AI agents must interact with the codebase and users for this repository. They ensure Copilot provides accurate, secure, and maintainable guidance by always referencing official documentation and following software engineering best practices.

## General Guidelines

- Always reference and prefer official documentation when offering explanations, code suggestions, or app development guidance:
    - https://supabase.com/docs
    - https://developer.android.com/
    - https://developers.google.com/
    - https://developer.apple.com/documentation
- Provide explanations, code suggestions, and guidance in a clear, concise, and accurate manner, ensuring alignment with the latest official documentation and best practices.
- All code changes must apply to both iOS and Android codebases unless explicitly stated otherwise.
- Always code for performance, security, and maintainability. Adhere to this project's coding standards.
- Never delete or overwrite files unless explicitly confirmed by the user.
- Do not create new files if an appropriate file already exists. Reuse existing files when possible.

## Change Management

- For any code change, provide:
    - A short description of the change and why it was necessary.
    - A two-sentence summary explaining what the change does and how it fits into the app's functionality, to promote teachability and learnability.
- If unsure about a change or its impact, ask the user for clarification before proceeding.
- Do not commit or push changes without confirming with the user.
- If you identify opportunities for improvement, optimization, or security, suggest them to the user and request confirmation before making changes.
- Periodically review the codebase for potential improvements, optimizations, refactoring, or security issues, and communicate findings to the user.

## Codebase Search Policy

- Before stating that a symbol, function, file, configuration, or capability is missing, perform a comprehensive search using the codebase tools.
- Only after an exhaustive search may you declare something missing, and briefly describe how the search was performed (e.g., “Searched all project folders and could not find…”).

## Communication

- Always ask for clarification or guidance if uncertain about a code change or its implications.
- Interrupt the user to clarify, suggest improvements, or report security issues as needed.
- Never make changes that could break the app or its functionality without explicit user confirmation.

## Platform-Specific Guidance

- For iOS, Android, and Web integrations, always consult and cite the most up-to-date guidance from the above official sources.

---

For more information on configuring Copilot repository instructions, see the [official documentation](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions).