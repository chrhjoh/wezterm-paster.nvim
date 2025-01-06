local M = {}
local selected_pane = nil

local notify = function(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify(msg, level, {
    title = "wezterm-paster.nvim",
  })
end

local function get_pane_list()
  local handle = io.popen("wezterm cli list --format json")
  if handle then
    local result = handle:read("*a")
    handle:close()
    local panes = vim.fn.json_decode(result)
    local pane_list = {}
    for _, pane in ipairs(panes) do
      table.insert(pane_list, {
        id = pane.pane_id,
        description = string.format("ID: %d - %s", pane.pane_id, pane.title or "No Title"),
      })
    end
    return pane_list
  else
    notify("Failed to get pane list", vim.log.levels.ERROR)
    return {}
  end
end

function M.setup()
  vim.api.nvim_create_user_command("WezTermPaneSelect", function()
    if vim.fn.executable("wezterm") ~= 1 then
      return
    end

    local pane_list = get_pane_list()
    if #pane_list == 0 then
      notify("No panes available", vim.log.levels.WARN)
      return
    end

    vim.ui.select(pane_list, {
      prompt = "Select a WezTerm Pane:",
      format_item = function(item)
        return item.description
      end,
    }, function(selected)
      if selected then
        selected_pane = selected.id
        notify(string.format("Selected Pane ID: %d", selected_pane), vim.log.levels.INFO)
      else
        notify("No pane selected", vim.log.levels.WARN)
      end
    end)
  end, {})

  vim.api.nvim_create_user_command("WezTermPanePaste", function()
    if vim.fn.executable("wezterm") ~= 1 then
      return
    end
    if vim.fn.mode() == "n" then
      vim.cmd('normal! "vyy')
    elseif string.lower(vim.fn.mode()) == "v" then
      vim.cmd('normal! "vy')
    end

    local selection = vim.fn.getreg("v")
    local wezterm_cmd = string.format("wezterm cli send-text --no-paste --pane-id %s ", selected_pane)

    vim.fn.system(wezterm_cmd, selection)
    vim.fn.system(wezterm_cmd, "\n")
  end, { range = true })
end

return M
