local wezterm = require('wezterm')
local act = wezterm.action

local ssh_domains = {}
local ssh_groups = {}
local ssh_group_order = {}
for _, dom in ipairs(wezterm.default_ssh_domains()) do
   if not dom.name:match('^SSHMUX:') then
      local group = dom.name:match('^([^-]+)-') or 'unclassified'
      if not ssh_groups[group] then
         ssh_groups[group] = {}
         table.insert(ssh_group_order, group)
      end
      table.insert(ssh_groups[group], dom)
      table.insert(ssh_domains, dom)
   end
end
table.sort(ssh_group_order, function(a, b)
   if a == 'unclassified' then return false end
   if b == 'unclassified' then return true end
   return a < b
end)
for _, group in ipairs(ssh_group_order) do
   table.sort(ssh_groups[group], function(a, b) return a.name < b.name end)
end

local function action()
   local group_choices = {}
   for _, group in ipairs(ssh_group_order) do
      local count = #ssh_groups[group]
      table.insert(group_choices, {
         id = group,
         label = group .. ' (' .. count .. ')',
      })
   end

   return act.InputSelector({
      title = 'SSH: Select Group',
      choices = group_choices,
      fuzzy = true,
      fuzzy_description = 'SSH Group: ',
      action = wezterm.action_callback(function(window, pane, group_id)
         if not group_id then
            return
         end
         local domains = ssh_groups[group_id]
         if not domains then
            return
         end
         local domain_choices = {}
         for _, dom in ipairs(domains) do
            table.insert(domain_choices, {
               id = dom.name,
               label = dom.name,
            })
         end
         window:perform_action(
            act.InputSelector({
               title = 'SSH: ' .. group_id,
               choices = domain_choices,
               fuzzy = true,
               fuzzy_description = 'Connect to: ',
               action = wezterm.action_callback(function(inner_window, inner_pane, domain_name)
                  if not domain_name then
                     return
                  end
                  inner_window:perform_action(
                     act.SwitchToWorkspace({
                        name = domain_name,
                        spawn = { domain = { DomainName = domain_name } },
                     }),
                     inner_pane
                  )
               end),
            }),
            pane
         )
      end),
   })
end

return {
   ssh_domains = ssh_domains,
   action = action,
}
