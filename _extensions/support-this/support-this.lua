-- Lua modules for Quarto "support-this" extension
local yaml = require("tinyyaml")
local platforms = require("platforms")

-- Global debug flag
local debug_enabled = false

-- Debug logging function
local function debug_log(message)
  if debug_enabled then
    quarto.log.output("[support-this] " .. message)
  end
end

-- Read FUNDING.yml file if it exists
local function read_funding_yml()
  local file = io.open("FUNDING.yml", "r")
  if not file then
    file = io.open(".github/FUNDING.yml", "r")
  end
  
  if file then
    local content = file:read("*all")
    file:close()
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

-- Parse configuration from metadata
local function get_config(meta)
  local config = {}
  
  -- Read from extensions.support-this or extensions.support_this
  local ext_config = nil
  if meta.extensions then
    if meta.extensions["support-this"] then
      ext_config = meta.extensions["support-this"]
    elseif meta.extensions.support_this then
      ext_config = meta.extensions.support_this
    end
  end
  
  if ext_config then
    -- Get debug setting first
    if ext_config.debug ~= nil then
      debug_enabled = ext_config.debug
      debug_log("Debug mode enabled")
    end
    
    -- Get heading and description
    if ext_config.heading then
      config.heading = pandoc.utils.stringify(ext_config.heading)
    end
    if ext_config.description then
      config.description = pandoc.utils.stringify(ext_config.description)
    end

    -- Get position and truncated settings
    if ext_config.position then
      config.position = pandoc.utils.stringify(ext_config.position)
    end
    if ext_config.truncated ~= nil then
      config.truncated = ext_config.truncated
    else
      config.truncated = false
    end

    -- Determine whether to use FUNDING.yml
    if ext_config.use_funding_yml ~= nil then
      config.use_funding_yml = ext_config.use_funding_yml
    else
      config.use_funding_yml = true
    end
    
    -- Get platform accounts
    config.accounts = {}
    for key, value in pairs(ext_config) do
      local key_str = pandoc.utils.stringify(key)
      local norm_key = normalize_platform_key(key_str)
      
      -- Skip non-platform keys
      if platforms[norm_key] and 
         key_str ~= "heading" and 
         key_str ~= "description" and 
         key_str ~= "position" and 
         key_str ~= "truncated" and 
         key_str ~= "debug" and
         key_str ~= "use_funding_yml" then
        
        config.accounts[norm_key] = {}
        
        debug_log(string.format("Processing %s", norm_key))
        debug_log(string.format("  type(value) = %s", type(value)))
        if type(value) == "table" then
          debug_log(string.format("  value.t = %s", tostring(value.t)))
          debug_log(string.format("  #value = %d", #value))
        end
        
        -- Check if value is a table/array (could be MetaList or plain table)
        if type(value) == "table" and #value > 0 then
          -- It's an array - iterate through items
          debug_log(string.format("Found array for %s with %d items", norm_key, #value))
          
          for i = 1, #value do
            local item = value[i]
            local item_value = pandoc.utils.stringify(item)
            debug_log(string.format("  [%d] stringified='%s'", i, item_value))
            
            if item_value and item_value ~= "" then
              table.insert(config.accounts[norm_key], item_value)
              debug_log(string.format("  [%d] INSERTED into config.accounts", i))
            end
          end
          
          debug_log(string.format("Final array length: %d", #config.accounts[norm_key]))
        elseif type(value) == "table" and value.t == "MetaInlines" then
          -- Single MetaInlines value
          local single_value = pandoc.utils.stringify(value)
          debug_log(string.format("Found single MetaInlines for %s: '%s'", norm_key, single_value))
          
          if single_value and single_value ~= "" then
            table.insert(config.accounts[norm_key], single_value)
          end
        else
          -- Try to stringify whatever it is
          local single_value = pandoc.utils.stringify(value)
          debug_log(string.format("Found other value for %s: '%s'", norm_key, single_value))
          
          if single_value and single_value ~= "" then
            table.insert(config.accounts[norm_key], single_value)
          end
        end
      end
    end
  else
    config.use_funding_yml = true
  end
  
  -- Read from FUNDING.yml if enabled
  if config.use_funding_yml then
    local funding_data = read_funding_yml()
    if funding_data then
      config.accounts = config.accounts or {}
      for key, value in pairs(funding_data) do
        local norm_key = normalize_platform_key(key)
        if platforms[norm_key] then
          if type(value) == "table" then
            config.accounts[norm_key] = value
          else
            config.accounts[norm_key] = {value}
          end
        end
      end
    end
  end
  
  -- Set defaults
  config.heading = config.heading or "Support This Project"
  config.position = config.position or "bottom"
  config.truncated = config.truncated or false
  
  return config
end

-- Generate support section for HTML format
local function generate_html_support(config)
  local html = '<div class="support-this-section">\n'
  
  if config.heading then
    html = html .. '<h3 class="support-this-heading">' .. config.heading .. '</h3>\n'
  end
  
  if config.description then
    html = html .. '<p class="support-this-description">' .. config.description .. '</p>\n'
  end
  
  html = html .. '<ul class="support-this-links">\n'
  
  -- Sort platform keys for consistent ordering
  local sorted_platforms = {}
  for platform_key, _ in pairs(config.accounts or {}) do
    table.insert(sorted_platforms, platform_key)
  end
  table.sort(sorted_platforms)
  
  debug_log(string.format("Rendering HTML with %d platforms", #sorted_platforms))
  
  for _, platform_key in ipairs(sorted_platforms) do
    local usernames = config.accounts[platform_key]
    local platform = platforms[platform_key]
    
    if platform and usernames and type(usernames) == "table" then
      debug_log(string.format("Platform %s has %d usernames", platform_key, #usernames))
      
      -- Iterate through each username with numeric index
      for idx = 1, #usernames do
        local username = usernames[idx]
        
        -- Skip empty usernames
        if username and username ~= "" and type(username) == "string" then
          local url = platform.url(username)
          local display_text = username
          
          html = html .. '  <li class="support-this-item">\n'
          html = html .. '    <a href="' .. url .. '" class="support-this-link" target="_blank" rel="noopener">\n'
          html = html .. '      <span class="support-this-icon">' .. platform.icon_html .. '</span>\n'
          
          if config.truncated then
            -- Truncated mode: just "icon username"
            html = html .. '      <span class="support-this-username">' .. display_text .. '</span>\n'
          else
            -- Normal mode: "icon platform: username"
            html = html .. '      <span class="support-this-platform">' .. platform.name .. '</span>: '
            html = html .. '      <span class="support-this-username">' .. display_text .. '</span>\n'
          end
          
          html = html .. '    </a>\n'
          html = html .. '  </li>\n'
        end
      end
    end
  end
  
  html = html .. '</ul>\n'
  html = html .. '</div>\n'
  
  return pandoc.RawBlock("html", html)
end

-- Generate support section for LaTeX/PDF format
local function generate_latex_support(config)
  local latex = '\\begin{tcolorbox}[colback=gray!5,colframe=gray!40,title=' .. (config.heading or "Support This Project") .. ']\n'
  
  if config.description then
    latex = latex .. config.description .. '\n\n'
  end
  
  latex = latex .. '\\begin{itemize}\n'
  
  -- Sort platform keys for consistent ordering
  local sorted_platforms = {}
  for platform_key, _ in pairs(config.accounts or {}) do
    table.insert(sorted_platforms, platform_key)
  end
  table.sort(sorted_platforms)
  
  debug_log(string.format("Rendering LaTeX with %d platforms", #sorted_platforms))
  
  for _, platform_key in ipairs(sorted_platforms) do
    local usernames = config.accounts[platform_key]
    local platform = platforms[platform_key]
    
    if platform and usernames and type(usernames) == "table" then
      debug_log(string.format("Platform %s has %d usernames", platform_key, #usernames))
      
      -- Iterate through each username with numeric index
      for idx = 1, #usernames do
        local username = usernames[idx]
        
        -- Skip empty usernames
        if username and username ~= "" and type(username) == "string" then
          local url = platform.url(username)
          
          if config.truncated then
            -- Truncated mode: just "icon username"
            latex = latex .. '  \\item ' .. platform.icon_unicode .. ' '
            latex = latex .. '\\href{' .. url .. '}{\\texttt{' .. username .. '}}\n'
          else
            -- Normal mode: "icon platform: username"
            latex = latex .. '  \\item ' .. platform.icon_unicode .. ' \\textbf{' .. platform.name .. ':} '
            latex = latex .. '\\href{' .. url .. '}{\\texttt{' .. username .. '}}\n'
          end
        end
      end
    end
  end
  
  latex = latex .. '\\end{itemize}\n'
  latex = latex .. '\\end{tcolorbox}\n'
  
  return pandoc.RawBlock("latex", latex)
end

-- Generate support section for Typst format
local function generate_typst_support(config)
  local typst = '#block(\n'
  typst = typst .. '  fill: rgb("#f6f8fa"),\n'
  typst = typst .. '  stroke: rgb("#e1e4e8"),\n'
  typst = typst .. '  radius: 6pt,\n'
  typst = typst .. '  inset: 1.5em,\n'
  typst = typst .. ')[\n'
  
  if config.heading then
    typst = typst .. '  === ' .. config.heading .. '\n\n'
  end
  
  if config.description then
    typst = typst .. '  ' .. config.description .. '\n\n'
  end
  
  -- Sort platform keys for consistent ordering
  local sorted_platforms = {}
  for platform_key, _ in pairs(config.accounts or {}) do
    table.insert(sorted_platforms, platform_key)
  end
  table.sort(sorted_platforms)
  
  debug_log(string.format("Rendering Typst with %d platforms", #sorted_platforms))
  
  for _, platform_key in ipairs(sorted_platforms) do
    local usernames = config.accounts[platform_key]
    local platform = platforms[platform_key]
    
    if platform and usernames and type(usernames) == "table" then
      debug_log(string.format("Platform %s has %d usernames", platform_key, #usernames))
      
      for idx = 1, #usernames do
        local username = usernames[idx]
        
        if username and username ~= "" and type(username) == "string" then
          local url = platform.url(username)
          
          if config.truncated then
            -- Truncated mode: just "icon username"
            typst = typst .. '  - ' .. platform.icon_typst .. ' '
            typst = typst .. '#link("' .. url .. '")[`' .. username .. '`]\n'
          else
            -- Normal mode: "icon platform: username"
            typst = typst .. '  - ' .. platform.icon_typst .. ' *' .. platform.name .. ':* '
            typst = typst .. '#link("' .. url .. '")[`' .. username .. '`]\n'
          end
        end
      end
    end
  end
  
  typst = typst .. ']\n'
  
  return pandoc.RawBlock("typst", typst)
end

-- Generate support section for generic formats (Markdown, Word, etc.)
local function generate_generic_support(config)
  local blocks = {}
  
  -- Add heading
  if config.heading then
    table.insert(blocks, pandoc.Header(3, pandoc.Str(config.heading)))
  end
  
  -- Add description
  if config.description then
    table.insert(blocks, pandoc.Para(pandoc.Str(config.description)))
  end
  
  -- Add links as bullet list
  local items = {}
  
  -- Sort platform keys for consistent ordering
  local sorted_platforms = {}
  for platform_key, _ in pairs(config.accounts or {}) do
    table.insert(sorted_platforms, platform_key)
  end
  table.sort(sorted_platforms)
  
  debug_log(string.format("Rendering generic format with %d platforms", #sorted_platforms))
  
  for _, platform_key in ipairs(sorted_platforms) do
    local usernames = config.accounts[platform_key]
    local platform = platforms[platform_key]
    
    if platform and usernames and type(usernames) == "table" then
      debug_log(string.format("Platform %s has %d usernames", platform_key, #usernames))
      
      -- Iterate through each username separately
      for idx = 1, #usernames do
        local username = usernames[idx]
        
        -- Skip empty usernames
        if username and username ~= "" and type(username) == "string" then
          local url = platform.url(username)
          local content = {}
          
          -- Add icon
          table.insert(content, pandoc.Str(platform.icon_unicode))
          table.insert(content, pandoc.Space())
          
          if config.truncated then
            -- Truncated mode: just "icon username"
            table.insert(content, pandoc.Link(pandoc.Str(username), url))
          else
            -- Normal mode: "icon platform: username"
            table.insert(content, pandoc.Strong(pandoc.Str(platform.name .. ":")))
            table.insert(content, pandoc.Space())
            table.insert(content, pandoc.Link(pandoc.Str(username), url))
          end
          
          -- Each username gets its own bullet item
          table.insert(items, {pandoc.Plain(content)})
        end
      end
    end
  end
  
  if #items > 0 then
    table.insert(blocks, pandoc.BulletList(items))
  end
  
  return blocks
end

-- Generate support section based on format
local function generate_support_section(config)
  if not config.accounts or not next(config.accounts) then
    return nil
  end
  
  if quarto.doc.is_format("html:js") then
    debug_log("Detected HTML format")
    return generate_html_support(config)
  elseif quarto.doc.is_format("pdf") then
    debug_log("Detected PDF format")
    return generate_latex_support(config)
  elseif quarto.doc.is_format("typst") then
    debug_log("Detected Typst format")
    return generate_typst_support(config)
  else
    debug_log("Detected generic format")
    return generate_generic_support(config)
  end
end

-- Store the support section for later insertion
local support_section = nil
local support_config = nil

-- Meta filter to add dependencies
function Meta(meta)
  support_config = get_config(meta)
  
  -- Add CSS dependency for HTML
  if quarto.doc.is_format("html:js") then
    debug_log("Adding HTML CSS dependency")
    quarto.doc.add_html_dependency({
      name = "support-this",
      version = "1.0.0",
      stylesheets = {"support-this.css"}
    })
  end
  
  -- Add LaTeX package for PDF
  if quarto.doc.is_format("pdf") then
    debug_log("Adding tcolorbox LaTeX package")
    quarto.doc.include_text("in-header", "\\usepackage{tcolorbox}")
  end
  
  return meta
end

-- Main Pandoc filter function
function Pandoc(doc)
  if not support_config or not support_config.accounts or not next(support_config.accounts) then
    debug_log("No accounts configured, skipping support section")
    return doc
  end
  
  support_section = generate_support_section(support_config)
  
  if not support_section then
    debug_log("No support section generated")
    return doc
  end
  
  -- Handle positioning
  if support_config.position == "top" then
    debug_log("Inserting support section at top")
    if type(support_section) == "table" then
      for i = #support_section, 1, -1 do
        table.insert(doc.blocks, 1, support_section[i])
      end
    else
      table.insert(doc.blocks, 1, support_section)
    end
  elseif support_config.position == "bottom" then
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
  -- For "custom" position, the Div filter below will handle it
  
  return doc
end

-- Handle custom placement via div
function Div(div)
  if div.classes:includes("support-this") and support_config and support_section then
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