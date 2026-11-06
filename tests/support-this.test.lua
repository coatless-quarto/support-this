-- support-this tests. Run from the repo root: quarto pandoc lua path/to/qtest.lua
local t = require("qtest")
local platforms = require("support-this-platforms")
local here = pandoc.system.get_working_directory()

-- Word output needs a PNG icon for every platform, not only the ones a
-- fixture happens to use
t.test("every platform has its fields, an inline SVG and a Word icon", function()
  for key, p in pairs(platforms) do
    for _, field in ipairs({ "name", "icon_html", "icon_png", "icon_unicode", "badge_color", "url_prefix" }) do
      t.ok(type(p[field]) == "string", key .. "." .. field .. " is a string")
    end
    t.ok(p.icon_html:find("<svg", 1, true), key .. ".icon_html is an inline SVG")
    local png = pandoc.path.join({ here, "_extensions", "support-this", p.icon_png })
    t.ok(pandoc.path.exists(png, "file"), key .. " icon " .. p.icon_png .. " exists")
  end
end)

t.test("html: heading, description, then links by platform name with custom links last, at the bottom", function()
  local r = t.render("basic.qmd", "html")
  r:succeeded()
  t.count(r.text, '<div class="support-this-section">', 1)
  t.in_order(r.text, {
    "Body text.",
    '<h3 class="support-this-heading', "Help out",
    '<p class="support-this-description">Thanks for reading.',
    'href="https://github.com/sponsors/octocat"',
    'href="https://www.patreon.com/maker"',
    'href="https://example.com/give--now"',
  })
end)

-- Regressions: Markdown's smart punctuation turned "--" into an en dash and
-- quotes into curly quotes, and accounts went into the HTML unescaped.
t.test("accounts keep -- and quotes as typed, and are escaped in the HTML", function()
  local r = t.render("basic.qmd", "html")
  t.contains(r.text, 'href="https://example.com/give--now"')
  t.contains(r.text, 'href="https://example.com/?q=&quot;x&quot;&amp;y=1"')
  t.not_contains(r.text, "give\u{2013}now")
end)

-- Regression: badges used shields.io's /badge/ path, where "-" and "_" are
-- separators, so an account such as my-user_name gave a broken image.
t.test("display: badge builds a shields.io query URL that keeps - and _", function()
  local r = t.render("badge.qmd", "html")
  r:succeeded()
  t.contains(r.text, 'src="https://img.shields.io/static/v1?label=GitHub%20Sponsors&amp;message=my-user_name&amp;')
end)

-- Regression: the section went to `position` even when the page had a
-- ::: {.support-this} div.
t.test("a .support-this div places the section there, whatever position says", function()
  local r = t.render("placed.qmd", "html")
  r:succeeded()
  t.count(r.text, '<div class="support-this-section">', 1)
  t.in_order(r.text, { "Before.", '<div class="support-this-section">', "After." })
end)

t.test("heading: false leaves the heading out", function()
  local r = t.render("no-heading.qmd", "html")
  r:succeeded()
  t.contains(r.text, 'href="https://github.com/sponsors/octocat"')
  t.not_contains(r.text, "support-this-heading")
end)

-- Quarto 1.11 merges a page's options with the project's, so `{}` no longer
-- turns the section off; the docs say to use false.
t.test("in a project, support-this: false on a page turns the shared section off", function()
  local r = t.render("site", "html", { output = "site/on.html", read = { "site/off.html" } })
  r:succeeded()
  t.count(r.text, '<div class="support-this-section">', 1)
  t.not_contains(r.extra["site/off.html"] or "", "support-this-section")
end)

t.test("revealjs: the section gets a slide of its own with a plain heading", function()
  local r = t.render("basic.qmd", "revealjs")
  r:succeeded()
  t.in_order(r.text, { '<section class="slide level2">', "<h3>Help out</h3>", "sponsors/octocat" })
end)

t.test("typst: the links get the SVG icons", function()
  local r = t.render("basic.qmd", "typst")
  r:succeeded()
  t.count(r.text, "image(bytes(", 4)
  t.contains(r.text, "https://github.com/sponsors/octocat")
end)

t.test("docx: the links get the PNG icons", function()
  local r = t.render("basic.qmd", "docx")
  r:succeeded()
  local icons = {}
  r.doc:walk({ Image = function(img) icons[#icons + 1] = pandoc.utils.stringify(img.caption) end })
  t.in_order(table.concat(icons, "|"), { "GitHub Sponsors", "Patreon", "Support", "Support" })
  t.contains(r.text, "https://github.com/sponsors/octocat")
end)

t.test("pdf (LaTeX): the links come without icons, which LaTeX fonts can't show", function()
  local r = t.render("basic.qmd", "latex")
  r:succeeded()
  t.contains(r.text, "\\textbf{GitHub Sponsors:}")
  t.contains(r.text, "\\href{https://github.com/sponsors/octocat}{octocat}")
  t.not_contains(r.text, "includegraphics")
end)
