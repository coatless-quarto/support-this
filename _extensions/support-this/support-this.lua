-- Lua module for Quarto "support-this" extension
local platforms = require("support-this-platforms")

---@alias SupportThisDisplay "icon-platform-username"|"icon-username"|"text"|"badge"
---@alias SupportThisPosition "top"|"bottom"|"custom"

---@class SupportThisConfig
---@field debug boolean Log what the filter does
---@field heading string? Heading of the support section; nil when turned off
---@field description string? Message shown above the links
---@field position SupportThisPosition Where the section goes
---@field display SupportThisDisplay How each link is shown; unknown values render like the default
---@field use_funding_yml boolean Also read accounts from FUNDING.yml
---@field accounts table<string, string[]> Accounts per platform key

---@class SupportThisEntry
---@field platform SupportThisPlatform
---@field account string Username, project or URL, as configured
---@field url string Link to the account

-- Configuration with default values
---@type SupportThisConfig
local config = {
  debug = false,
  heading = "Support This Project",
  description = nil,
  position = "bottom",
  display = "icon-platform-username",
  use_funding_yml = false,
  accounts = {}
}

-- Debug logging function
---@param message string
local function debug_log(message)
  if config.debug then
    quarto.log.output("[support-this] " .. message)
  end
end

-- Find the nearest directory at or above dir that holds a git repository
---@param dir string
---@return string?
local function find_repo_root(dir)
  while true do
    local ok, entries = pcall(pandoc.system.list_directory, dir)
    if ok then
      for _, entry in ipairs(entries) do
        if entry == ".git" then
          return dir
        end
      end
    end
    local parent = pandoc.path.directory(dir)
    if parent == dir then
      return nil
    end
    dir = parent
  end
end

-- Open the first FUNDING.yml found. Look next to the document first (Quarto
-- renders from the document's directory), then at the project root, then at
-- the root of the git repository, where GitHub keeps it in .github/
---@return file*? file
---@return string? path
local function open_funding_yml()
  local project_dir = quarto.project.directory
  local repo_dir = find_repo_root(project_dir or pandoc.system.get_working_directory())
  for _, dir in ipairs({".", project_dir or ".", repo_dir or "."}) do
    for _, path in ipairs({
      pandoc.path.join({dir, "FUNDING.yml"}),
      pandoc.path.join({dir, ".github", "FUNDING.yml"})
    }) do
      local file = io.open(path, "r")
      if file then
        return file, path
      end
    end
  end
  return nil, nil
end

-- Read FUNDING.yml, if there is one, as metadata
---@return pandoc.Meta?
local function read_funding_yml()
  local file, path = open_funding_yml()
  if not file then
    return nil
  end
  local content = file:read("a") or ""
  file:close()
  debug_log("Reading " .. tostring(path))

  -- Parse it as a YAML metadata block, so its values come back like the
  -- document's own platforms. The block has to start on the line after the
  -- opening ---, so drop a byte-order mark, blank lines and a YAML
  -- document-start line first. Without smart punctuation, "a--b" stays as is
  content = content:gsub("^\239\187\191", ""):gsub("^%s*", ""):gsub("^%-%-%-[ \t]*\r?\n", ""):gsub("^%s*", "")
  local ok, doc = pcall(pandoc.read, "---\n" .. content .. "\n---\n", "markdown-smart")
  if not ok then
    quarto.log.warning("[support-this] Could not read " .. tostring(path) .. ": " .. tostring(doc))
    return nil
  end
  return doc.meta
end

-- Normalize platform keys to handle both snake_case and variations
---@param key string
---@return string
local function normalize_platform_key(key)
  local normalized = key:lower():gsub("-", "_")
  return normalized
end

-- Read one platform's accounts. A YAML list gives one account per item. A
-- single string is a table too (its inlines), so it is told apart by type,
-- not length, or it would be split at spaces
---@param value any
---@return string[]
local function read_accounts(value)
  local items = pandoc.utils.type(value) == "List" and value or {value}
  local accounts = {}
  for _, item in ipairs(items) do
    local account = pandoc.utils.stringify(item)
    if account ~= "" then
      table.insert(accounts, account)
    end
  end
  return accounts
end

-- Add the accounts of every known platform in a map of platform keys to
-- accounts. With keep_existing, platforms that are already set are skipped
---@param source table
---@param keep_existing boolean
local function add_accounts(source, keep_existing)
  for key, value in pairs(source) do
    local platform_key = normalize_platform_key(pandoc.utils.stringify(key))
    if platforms[platform_key] and not (keep_existing and config.accounts[platform_key]) then
      config.accounts[platform_key] = read_accounts(value)
      debug_log(platform_key .. ": " .. table.concat(config.accounts[platform_key], ", "))
    end
  end
end

-- Parse configuration from extensions.support-this (or support_this)
---@param meta pandoc.Meta
local function read_config(meta)
  local extensions = meta.extensions
  if type(extensions) ~= "table" then
    return
  end
  local options = extensions["support-this"] or extensions.support_this
  if type(options) ~= "table" then
    return
  end

  -- Update debug setting first
  if options.debug ~= nil then
    config.debug = pandoc.utils.stringify(options.debug) == "true"
    debug_log("Debug mode enabled")
  end

  -- Update heading (title is accepted as another name) and description.
  -- heading: false, or an empty heading, leaves the heading out
  local heading = options.heading
  if heading == nil then
    heading = options.title
  end
  if heading == false then
    config.heading = nil
  elseif heading ~= nil then
    local text = pandoc.utils.stringify(heading)
    config.heading = text ~= "" and text or nil
  end
  if options.description then
    config.description = pandoc.utils.stringify(options.description)
  end

  if options.position then
    local position = pandoc.utils.stringify(options.position)
    if position ~= "top" and position ~= "bottom" and position ~= "custom" then
      quarto.log.warning(string.format(
        '[support-this] Unknown position "%s"; use top, bottom or custom. Placing the section at the bottom.',
        position
      ))
      position = "bottom"
    end
    config.position = position --[[@as SupportThisPosition]]
  end

  if options.display then
    config.display = pandoc.utils.stringify(options.display) --[[@as SupportThisDisplay]]
  end

  if options.use_funding_yml ~= nil then
    config.use_funding_yml = options.use_funding_yml == true
  end

  -- Get platform accounts from platforms key
  config.accounts = {}
  local platforms_option = options.platforms
  if type(platforms_option) == "table" then
    debug_log("Found platforms configuration")
    add_accounts(platforms_option, false)
  end

  -- FUNDING.yml is the base: a platform also set in the document's
  -- platforms keeps the document's accounts
  if config.use_funding_yml then
    local funding = read_funding_yml()
    if funding then
      add_accounts(funding, true)
    end
  end
end

-- Collect the links to show: platforms in key order, each platform's
-- accounts in the order they are listed
---@return SupportThisEntry[]
local function collect_entries()
  local platform_keys = {}
  for platform_key in pairs(config.accounts) do
    table.insert(platform_keys, platform_key)
  end
  table.sort(platform_keys)

  local entries = {}
  for _, platform_key in ipairs(platform_keys) do
    local platform = platforms[platform_key]
    for _, account in ipairs(config.accounts[platform_key]) do
      local url = platform.url_prefix .. account
      -- Bare domains such as example.com/donate would be relative links;
      -- treat them as https, as GitHub does for FUNDING.yml
      if not url:match("^%a[%w+.-]*:") then
        url = "https://" .. url
      end
      table.insert(entries, {platform = platform, account = account, url = url})
    end
  end
  return entries
end

-- Generate the list items for the links (non-HTML formats and RevealJS)
---@param entries SupportThisEntry[]
---@return pandoc.List
local function generate_links_content(entries)
  -- LaTeX's default fonts have no glyphs for the icon symbols and emoji,
  -- which come out as missing characters, so LaTeX output is text only
  local show_icons = not quarto.doc.is_format("latex")

  local items = pandoc.List({})
  for _, entry in ipairs(entries) do
    local platform, account, url = entry.platform, entry.account, entry.url
    local content = pandoc.Inlines({})

    if config.display == "text" then
      -- Text mode: just platform name as link
      content:insert(pandoc.Link({pandoc.Strong({pandoc.Str(platform.name)})}, url))

    elseif config.display == "icon-username" and show_icons then
      -- Icon + username mode
      content:insert(pandoc.Str(platform.icon_unicode))
      content:insert(pandoc.Space())
      content:insert(pandoc.Link({pandoc.Str(account)}, url))

    else
      -- Default and badge: icon-platform-username mode. Without icons,
      -- icon-username also lands here, so the platform name still says
      -- where each link goes
      if show_icons then
        content:insert(pandoc.Str(platform.icon_unicode))
        content:insert(pandoc.Space())
      end
      content:insert(pandoc.Strong({pandoc.Str(platform.name .. ":")}))
      content:insert(pandoc.Space())
      content:insert(pandoc.Link({pandoc.Str(account)}, url))
    end

    items:insert({pandoc.Plain(content)})
  end
  return items
end

-- Percent-encode a string for use as a URL query value
---@param str string
---@return string
local function url_encode(str)
  return (str:gsub("[^%w%-%._~]", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

-- Escape text for HTML content and double-quoted attribute values
---@param str string
---@return string
local function html_escape(str)
  return (str:gsub('[&<>"]', {["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;", ['"'] = "&quot;"}))
end

-- Generate support section for HTML format
---@param entries SupportThisEntry[]
---@return pandoc.Blocks
local function generate_html_support(entries)
  local html = '<div class="support-this-section">\n'
  if config.heading then
    html = html .. '<h3 class="support-this-heading">' .. html_escape(config.heading) .. '</h3>\n'
  end

  if config.description then
    html = html .. '<p class="support-this-description">' .. html_escape(config.description) .. '</p>\n'
  end

  html = html .. '<ul class="support-this-links">\n'
  debug_log(string.format("Rendering HTML with %d links", #entries))

  for _, entry in ipairs(entries) do
    local platform = entry.platform
    local name, account, url = html_escape(platform.name), html_escape(entry.account), html_escape(entry.url)
    html = html .. '  <li class="support-this-item">\n'

    if config.display == "badge" then
      -- Badge mode: shields.io static badge. The query form takes the
      -- label and message verbatim, unlike /badge/ paths, where "-" and
      -- "_" are separators
      local badge_url = string.format(
        "https://img.shields.io/static/v1?label=%s&message=%s&color=%s",
        url_encode(platform.name),
        url_encode(entry.account),
        platform.badge_color
      )
      if platform.badge_logo then
        badge_url = badge_url .. "&logo=" .. platform.badge_logo
      end
      html = html .. '    <a href="' .. url .. '" target="_blank" rel="noopener">\n'
      html = html .. '      <img src="' .. html_escape(badge_url) .. '" alt="' .. name .. ': ' .. account .. '">\n'
      html = html .. '    </a>\n'

    elseif config.display == "text" then
      -- Text mode: just platform name as link
      html = html .. '    <a href="' .. url .. '" class="support-this-link" target="_blank" rel="noopener">\n'
      html = html .. '      <span class="support-this-platform">' .. name .. '</span>\n'
      html = html .. '    </a>\n'

    elseif config.display == "icon-username" then
      -- Icon + username mode
      html = html .. '    <a href="' .. url .. '" class="support-this-link" target="_blank" rel="noopener">\n'
      html = html .. '      <span class="support-this-icon">' .. platform.icon_html .. '</span>\n'
      html = html .. '      <span class="support-this-username">' .. account .. '</span>\n'
      html = html .. '    </a>\n'

    else
      -- Default: icon-platform-username mode
      html = html .. '    <a href="' .. url .. '" class="support-this-link" target="_blank" rel="noopener">\n'
      html = html .. '      <span class="support-this-icon">' .. platform.icon_html .. '</span>\n'
      html = html .. '      <span class="support-this-platform">' .. name .. '</span>: '
      html = html .. '      <span class="support-this-username">' .. account .. '</span>\n'
      html = html .. '    </a>\n'
    end

    html = html .. '  </li>\n'
  end

  html = html .. '</ul>\n'
  html = html .. '</div>\n'

  return pandoc.Blocks({pandoc.RawBlock("html", html)})
end

-- Generate support section using Quarto Callout (for non-HTML/RevealJS formats)
---@param entries SupportThisEntry[]
---@return pandoc.Blocks
local function generate_callout_support(entries)
  local content = pandoc.Blocks({})
  if config.description then
    content:insert(pandoc.Para({pandoc.Str(config.description)}))
  end
  content:insert(pandoc.BulletList(generate_links_content(entries)))

  -- Quarto titles an untitled callout "Note" in Typst and shows an empty
  -- title in Word, so without a heading the description and links stand alone
  if not config.heading then
    return content
  end

  -- Build the callout with Quarto's API: a raw .callout-note div added at
  -- this point is never turned into a callout. quarto.Callout returns two
  -- values, so keep only the first
  local callout = (quarto.Callout({
    type = "note",
    title = config.heading,
    content = content
  })) --[[@as pandoc.Block]]

  return pandoc.Blocks({callout})
end

-- Generate support section for RevealJS
---@param entries SupportThisEntry[]
---@param own_slide boolean Start a non-titled slide for the section
---@return pandoc.Blocks
local function generate_revealjs_support(entries, own_slide)
  local blocks = pandoc.Blocks({})

  -- At the top or bottom, create a non-titled slide with a level 2 header
  -- (empty). In a .support-this div, the section stays on the div's slide
  if own_slide then
    blocks:insert(pandoc.Header(2, {}))
  end
  if config.heading then
    blocks:insert(pandoc.Header(3, {pandoc.Str(config.heading)}))
  end

  if config.description then
    blocks:insert(pandoc.Para({pandoc.Str(config.description)}))
  end

  blocks:insert(pandoc.BulletList(generate_links_content(entries)))
  return blocks
end

-- Generate support section based on format
---@param entries SupportThisEntry[]
---@param in_place boolean The section replaces a .support-this div
---@return pandoc.Blocks
local function generate_support_section(entries, in_place)
  -- Check RevealJS BEFORE html:js (RevealJS is HTML-based)
  if quarto.doc.is_format("revealjs") then
    debug_log("Detected RevealJS format")
    return generate_revealjs_support(entries, not in_place)
  elseif quarto.doc.is_format("html:js") then
    debug_log("Detected HTML format")
    return generate_html_support(entries)
  else
    debug_log("Detected non-HTML format (using Callout API)")
    return generate_callout_support(entries)
  end
end

-- Meta filter: read the configuration and add the CSS dependency for HTML pages
---@param meta pandoc.Meta
---@return pandoc.Meta
local function read_meta(meta)
  read_config(meta)

  -- RevealJS gets plain headings and lists, which the stylesheet doesn't style
  if quarto.doc.is_format("html:js") and not quarto.doc.is_format("revealjs") then
    debug_log("Adding HTML CSS dependency")
    quarto.doc.add_html_dependency({
      name = "support-this",
      version = "1.0.0",
      stylesheets = {"support-this.css"}
    })
  end

  return meta
end

-- Pandoc filter: build the section and put it in place. A ::: {.support-this}
-- div marks where the author wants it, whatever position says; without one,
-- position puts it at the top or bottom
---@param doc pandoc.Pandoc
---@return pandoc.Pandoc
local function place_section(doc)
  local entries = collect_entries()
  if #entries == 0 then
    debug_log("No accounts configured, skipping support section")
    return doc
  end

  -- Blocks:walk returns Blocks; the type stubs inherit List:walk's return type
  local placeholders = 0
  local in_place = nil
  doc.blocks = doc.blocks:walk({
    Div = function(div)
      if div.classes:includes("support-this") then
        placeholders = placeholders + 1
        in_place = in_place or generate_support_section(entries, true)
        return in_place
      end
    end
  }) --[[@as pandoc.Blocks]]

  if placeholders > 0 then
    debug_log(string.format("Replaced %d .support-this div(s) with the support section", placeholders))
  elseif config.position == "top" then
    debug_log("Inserting support section at top")
    doc.blocks = generate_support_section(entries, false) .. doc.blocks
  elseif config.position == "bottom" then
    debug_log("Inserting support section at bottom")
    doc.blocks:extend(generate_support_section(entries, false))
  else
    quarto.log.warning(
      "[support-this] position is custom, but the document has no ::: {.support-this} div, so the support section is left out."
    )
  end

  return doc
end

return {
  {Meta = read_meta},
  {Pandoc = place_section}
}
