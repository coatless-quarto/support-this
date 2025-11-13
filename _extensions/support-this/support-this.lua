-- Lua module for Quarto "support-this" extension
local platforms_module = require("platforms")

-- Global configuration with default values
local debug_enabled = true
local heading = "Support This Project"
local description = nil
local position = "bottom"
local display = "icon-platform-username"
local use_funding_yml = false
local accounts = {}

-- Debug logging function
local function debug_log(message)
  if debug_enabled then
    quarto.log.output("[support-this] " .. message)
  end
end

-- Read FUNDING.yml file if it exists (lazy load tinyyaml)
local function read_funding_yml()
  local file = io.open("FUNDING.yml", "r")
  if not file then
    file = io.open(".github/FUNDING.yml", "r")
  end
  
  if file then
    local content = file:read("*all")
    file:close()
    
    -- Only load tinyyaml when we actually need it
    local yaml = require("tinyyaml")
    local success, parsed = pcall(yaml.parse, content)
    if success then
      return parsed
    end
  end
  
  return nil
end

-- Normalize platform keys to handle both snake_case and variations
local function normalize_platform_key(key)
  local normalized = key:lower():gsub("-", "_")
  return normalized
end

-- Parse configuration from metadata and update global variables
local function get_config(meta)
  -- Read from extensions.support-this or extensions.support_this
  local ext_config = nil
  if meta.extensions then
    if meta.extensions["support-this"] then
      ext_config = meta.extensions["support-this"]
    elseif meta.extensions.support_this then
      ext_config = meta.extensions.support_this
    end
  end
  
  if not ext_config then
    return
  end
  
  -- Update debug setting first
  if ext_config.debug ~= nil then
    debug_enabled = pandoc.utils.stringify(ext_config.debug) == "true"
    debug_log("Debug mode enabled")
  end
  
  -- Update heading and description
  if ext_config.heading then
    heading = pandoc.utils.stringify(ext_config.heading)
  elseif ext_config.title then
    heading = pandoc.utils.stringify(ext_config.title)
  end
  
  if ext_config.description then
    description = pandoc.utils.stringify(ext_config.description)
  end
  
  -- Update position
  if ext_config.position then
    position = pandoc.utils.stringify(ext_config.position)
  end
  
  -- Update display mode
  if ext_config.display then
    display = pandoc.utils.stringify(ext_config.display)
  end
  
  -- Update use_funding_yml setting
  if ext_config.use_funding_yml ~= nil then
    use_funding_yml = ext_config.use_funding_yml
  end
  
  -- Get platform accounts from platforms key
  accounts = {}
  if ext_config.platforms then
    debug_log("Found platforms configuration")
    for key, value in pairs(ext_config.platforms) do
      local key_str = pandoc.utils.stringify(key)
      local norm_key = normalize_platform_key(key_str)
      
      if platforms_module[norm_key] then
        accounts[norm_key] = {}
        
        debug_log(string.format("Processing platform: %s", norm_key))
        if type(value) == "table" then
          debug_log(string.format("  #value = %d", #value))
        end
        
        -- Check if value is a table/array
        if type(value) == "table" and #value > 0 then
          -- It's an array - iterate through items
          debug_log(string.format("Found array for %s with %d items", norm_key, #value))
          
          for i = 1, #value do
            local item = value[i]
            local item_value = pandoc.utils.stringify(item)
            debug_log(string.format("  [%d] = '%s'", i, item_value))
            
            if item_value and item_value ~= "" then
              table.insert(accounts[norm_key], item_value)
            end
          end
        else
          -- Single value
          local single_value = pandoc.utils.stringify(value)
          debug_log(string.format("Found single value for %s: '%s'", norm_key, single_value))
          
          if single_value and single_value ~= "" then
            table.insert(accounts[norm_key], single_value)
          end
        end
      end
    end
  end
  
  -- Read from FUNDING.yml if enabled (only load tinyyaml if needed)
  if use_funding_yml == true then
    debug_log("Loading FUNDING.yml")
    local funding_data = read_funding_yml()
    if funding_data then
      for key, value in pairs(funding_data) do
        local norm_key = normalize_platform_key(key)
        if platforms_module[norm_key] then
          if type(value) == "table" then
            accounts[norm_key] = value
          else
            accounts[norm_key] = {value}
          end
        end
      end
    end
  end
end

-- Generate support links content (used across formats)
local function generate_links_content()
  local items = {}
  
  -- Sort platform keys for consistent ordering
  local sorted_platforms = {}
  for platform_key, _ in pairs(accounts) do
    table.insert(sorted_platforms, platform_key)
  end
  table.sort(sorted_platforms)
  
  for _, platform_key in ipairs(sorted_platforms) do
    local usernames = accounts[platform_key]
    local platform = platforms_module[platform_key]
    
    if platform and usernames and type(usernames) == "table" then
      for idx = 1, #usernames do
        local username = usernames[idx]
        
        if username and username ~= "" and type(username) == "string" then
          local url = platform.url(username)
          local content = {}
          
          if display == "text" then
            -- Text mode: just platform name as link
            table.insert(content, pandoc.Link(pandoc.Strong(pandoc.Str(platform.name)), url))
            
          elseif display == "icon-username" then
            -- Icon + username mode
            table.insert(content, pandoc.Str(platform.icon_unicode))
            table.insert(content, pandoc.Space())
            table.insert(content, pandoc.Link(pandoc.Str(username), url))
            
          else
            -- Default and badge: icon-platform-username mode
            table.insert(content, pandoc.Str(platform.icon_unicode))
            table.insert(content, pandoc.Space())
            table.insert(content, pandoc.Strong(pandoc.Str(platform.name .. ":")))
            table.insert(content, pandoc.Space())
            table.insert(content, pandoc.Link(pandoc.Str(username), url))
          end
          
          table.insert(items, {pandoc.Plain(content)})
        end
      end
    end
  end
  
  return items
end

-- Generate support section for HTML format
local function generate_html_support()
  local html = '<div class="support-this-section">\n'
  
  if heading then
    html = html .. '<h3 class="support-this-heading">' .. heading .. '</h3>\n'
  end
  
  if description then
    html = html .. '<p class="support-this-description">' .. description .. '</p>\n'
  end
  
  html = html .. '<ul class="support-this-links">\n'
  
  -- Sort platform keys for consistent ordering
  local sorted_platforms = {}
  for platform_key, _ in pairs(accounts) do
    table.insert(sorted_platforms, platform_key)
  end
  table.sort(sorted_platforms)
  
  debug_log(string.format("Rendering HTML with %d platforms", #sorted_platforms))
  
  for _, platform_key in ipairs(sorted_platforms) do
    local usernames = accounts[platform_key]
    local platform = platforms_module[platform_key]
    
    if platform and usernames and type(usernames) == "table" then
      for idx = 1, #usernames do
        local username = usernames[idx]
        
        if username and username ~= "" and type(username) == "string" then
          local url = platform.url(username)
          
          html = html .. '  <li class="support-this-item">\n'
          
          if display == "badge" then
            -- Badge mode: shields.io badge
            local badge_url = string.format(
              "https://img.shields.io/badge/%s-%s-%s?logo=%s",
              platform.name:gsub(" ", "%%20"),
              username:gsub(" ", "%%20"),
              platform.badge_color,
              platform.badge_logo
            )
            html = html .. '    <a href="' .. url .. '" target="_blank" rel="noopener">\n'
            html = html .. '      <img src="' .. badge_url .. '" alt="' .. platform.name .. ': ' .. username .. '">\n'
            html = html .. '    </a>\n'
            
          elseif display == "text" then
            -- Text mode: just platform name as link
            html = html .. '    <a href="' .. url .. '" class="support-this-link" target="_blank" rel="noopener">\n'
            html = html .. '      <span class="support-this-platform">' .. platform.name .. '</span>\n'
            html = html .. '    </a>\n'
            
          elseif display == "icon-username" then
            -- Icon + username mode
            html = html .. '    <a href="' .. url .. '" class="support-this-link" target="_blank" rel="noopener">\n'
            html = html .. '      <span class="support-this-icon">' .. platform.icon_html .. '</span>\n'
            html = html .. '      <span class="support-this-username">' .. username .. '</span>\n'
            html = html .. '    </a>\n'
            
          else
            -- Default: icon-platform-username mode
            html = html .. '    <a href="' .. url .. '" class="support-this-link" target="_blank" rel="noopener">\n'
            html = html .. '      <span class="support-this-icon">' .. platform.icon_html .. '</span>\n'
            html = html .. '      <span class="support-this-platform">' .. platform.name .. '</span>: '
            html = html .. '      <span class="support-this-username">' .. username .. '</span>\n'
            html = html .. '    </a>\n'
          end
          
          html = html .. '  </li>\n'
        end
      end
    end
  end
  
  html = html .. '</ul>\n'
  html = html .. '</div>\n'
  
  return pandoc.RawBlock("html", html)
end

-- Generate support section using Quarto Callout (for non-HTML/RevealJS formats)
local function generate_callout_support()
  local blocks = {}
  
  -- Add heading if provided
  if heading then
    table.insert(blocks, pandoc.Header(3, pandoc.Str(heading)))
  end
  
  -- Add description if provided
  if description then
    table.insert(blocks, pandoc.Para(pandoc.Str(description)))
  end
  
  -- Generate links
  local items = generate_links_content()
  
  if #items > 0 then
    -- Create callout content
    local callout_content = {}
    
    -- Add bullet list
    table.insert(callout_content, pandoc.BulletList(items))
    
    -- Wrap in Quarto callout div
    local callout = pandoc.Div(
      callout_content,
      pandoc.Attr("", {"callout-note"})
    )
    
    table.insert(blocks, callout)
  end
  
  return blocks
end

-- Generate support section for RevealJS (non-titled slide)
local function generate_revealjs_support()
  local blocks = {}
  
  -- Create non-titled slide with level 2 header (empty)
  table.insert(blocks, pandoc.Header(2, {}))
  
  -- Add heading as level 3 if provided
  if heading then
    table.insert(blocks, pandoc.Header(3, pandoc.Str(heading)))
  end
  
  -- Add description if provided
  if description then
    table.insert(blocks, pandoc.Para(pandoc.Str(description)))
  end
  
  -- Generate links
  local items = generate_links_content()
  
  if #items > 0 then
    table.insert(blocks, pandoc.BulletList(items))
  end
  
  return blocks
end

-- Generate support section based on format
local function generate_support_section()
  if not accounts or not next(accounts) then
    return nil
  end
  
  -- Check RevealJS BEFORE html:js (RevealJS is HTML-based)
  if quarto.doc.is_format("revealjs") then
    debug_log("Detected RevealJS format")
    return generate_revealjs_support()
  elseif quarto.doc.is_format("html:js") then
    debug_log("Detected HTML format")
    return generate_html_support()
  else
    debug_log("Detected non-HTML format (using Callout API)")
    return generate_callout_support()
  end
end

-- Store the support section for later insertion
local support_section = nil

-- Meta filter to add dependencies
function Meta(meta)
  get_config(meta)
  
  -- Add CSS dependency for HTML
  if quarto.doc.is_format("html:js") then
    debug_log("Adding HTML CSS dependency")
    quarto.doc.add_html_dependency({
      name = "support-this",
      version = "1.0.0",
      stylesheets = {"support-this.css"}
    })
  end
  
  return meta
end

-- Main Pandoc filter function
function Pandoc(doc)
  if not accounts or not next(accounts) then
    debug_log("No accounts configured, skipping support section")
    return doc
  end
  
  support_section = generate_support_section()
  
  if not support_section then
    debug_log("No support section generated")
    return doc
  end
  
  -- Handle positioning
  if position == "top" then
    debug_log("Inserting support section at top")
    if type(support_section) == "table" then
      for i = #support_section, 1, -1 do
        table.insert(doc.blocks, 1, support_section[i])
      end
    else
      table.insert(doc.blocks, 1, support_section)
    end
  elseif position == "bottom" then
    debug_log("Inserting support section at bottom")
    if type(support_section) == "table" then
      for _, block in ipairs(support_section) do
        table.insert(doc.blocks, block)
      end
    else
      table.insert(doc.blocks, support_section)
    end
  else
    debug_log("Support section will be placed at custom location")
  end
  
  return doc
end

-- Handle custom placement via div
function Div(div)
  if div.classes:includes("support-this") and support_section then
    debug_log("Replacing .support-this div with support section")
    if type(support_section) == "table" then
      return support_section
    else
      return {support_section}
    end
  end
end

return {
  {Meta = Meta},
  {Pandoc = Pandoc},
  {Div = Div}
}