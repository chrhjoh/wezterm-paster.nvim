local M = {}
local selected_pane = nil

local notify = function(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify(msg, level, {
    title = "wezterm-paster.nvim",
  })
end

local format_pane_description = function(pane)
  local window = pane.window_title ~= "" and pane.window_title or pane.window_id
  local tab = pane.tab_title ~= "" and pane.tab_title or pane.tab_id
  local title = pane.title ~= "" and pane.title or pane.pane_id
  return "Title: " .. title .. " Tab: " .. tab .. " Window: " .. window
end

local function get_pane_list(filter_current_workspace)
  local handle = io.popen("wezterm cli list --format json")
  if handle then
    local result = handle:read("*a")
    handle:close()
    local panes = vim.fn.json_decode(result)
    local pane_list = {}
    local current_pane = tonumber(vim.env.WEZTERM_PANE)
    local current_workspace = nil
    for _, pane in ipairs(panes) do
      if pane.pane_id == current_pane then
        current_workspace = pane.workspace
      end
      table.insert(pane_list, {
        id = pane.pane_id,
        description = format_pane_description(pane),
        workspace = pane.workspace,
      })
    end
    if filter_current_workspace ~= false and current_workspace then
      local filtered_panes = {}
      for _, pane in ipairs(pane_list) do
        if pane.workspace == current_workspace then
          table.insert(filtered_panes, pane)
        end
      end
      return filtered_panes
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
      prompt = "Select a WezTerm Pane: (Current Tab: " .. vim.env.WEZTERM_PANE .. ")",
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
    if vim.fn.executable("wezterm") ~= 1 or not selected_pane then
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
