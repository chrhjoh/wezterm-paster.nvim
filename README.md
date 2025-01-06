# WezTerm Paster Plugin

This Neovim plugin allows you to interact with WezTerm panes directly from Neovim. You can select a WezTerm pane and paste text from Neovim into the selected pane.

## Installation

To install this plugin with lazy add the following line to your Neovim configuration file:

```lua
{"chrhjoh/wezterm-paster.nvim",}
```
## Configuration
There are currently no setup functions. Just add the above line to your Neovim configuration, and call the setup function to load the below commands.

## Commands

### `:SelectWezPane`

This command allows you to select a WezTerm pane from a list of available panes. The selected pane will be used for subsequent paste operations.

Usage:
```
:WezTermPaneSelect
```

### `:PasteSelectionWezPane`

This command pastes the currently selected text in Neovim into the previously selected WezTerm pane. If no pane has been selected, you will need to run `:SelectWezPane` first.

This command pastes the current line in normal mode and the current selection in visual mode.

Usage:
```
:WezTermPanePaste
```

