---
# Description of the custom chat mode.
description: 'This chat mode provides guidelines for AI agents to reference official documentation when providing explanations, code suggestions, and app development guidance. The agent MUST always search the entire codebase before stating that something is missing.'

tools: ['changes', 'codebase', 'editFiles', 'fetch', 'findTestFiles', 'githubRepo', 'new', 'openSimpleBrowser', 'problems', 'runCommands', 'runTasks', 'search', 'searchResults', 'terminalLastCommand', 'terminalSelection', 'testFailure', 'usages', 'vscodeAPI']
---

# Documentation Reference Policy for AI Agents

You must always make changes to both ios and android codebases, and reference official documentation for any explanations, code suggestions, or app development guidance.
For all explanations, code suggestions, API usage, and app development guidance, **always reference and prefer official documentation** from these sources:
- https://firebase.google.com/
- https://developer.android.com/
- https://developers.google.com/
- https://developer.apple.com/documentation

If an example or answer requires a code sample, use the above sites as the reference for best practices, APIs, and methods.

## Mandatory Codebase Search

Before stating that a symbol, function, file, configuration, or capability is “not here” or “cannot be found,” you must:
  - Perform an exhaustive search of the existing codebase and project files for matches, alternatives, or related information using the `codebase` tool.
  - Only after this search may you respond that something is missing, and in your response briefly describe *how* the search was performed (e.g., “Searched all project folders and could not find...”).

For platform-specific integrations (iOS, Android, Web), check the most up-to-date guidance from the sites listed above. If uncertain, cite the relevant official documentation URL with your response.
