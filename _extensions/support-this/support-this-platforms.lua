-- Icons: the GitHub, Patreon, Ko-fi, Buy Me a Coffee, Liberapay, Open
-- Collective and Linux Foundation (for LFX) logos are from Simple Icons 16.34.0
-- (https://simpleicons.org), released under CC0-1.0; the brands themselves are
-- trademarks of their owners. Simple Icons has no logo for Tidelift, IssueHunt,
-- Polar or thanks.dev, so they and custom links use generic icons drawn for
-- this extension (a box, a target, a sparkle, a heart and a link). icons/
-- holds each icon_html rendered to a 64 x 64 PNG in #404040 for Word output.

---@class SupportThisPlatform
---@field name string Platform name shown in links and badges
---@field icon_html string Inline SVG icon for HTML output
---@field icon_png string The same icon as a PNG for Word output, relative to this module
---@field icon_unicode string Symbol shown before links in other formats
---@field badge_color string shields.io badge color
---@field badge_logo string? shields.io logo name; nil where shields has no logo for the platform
---@field url_prefix string Prepended to an account to build its link (custom accounts are full URLs)

---@type table<string, SupportThisPlatform>
local platforms = {
  github = {
    name = "GitHub Sponsors",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></svg>',
    icon_png = "icons/github.png",
    icon_unicode = "★",
    badge_color = "555",
    badge_logo = "github",
    url_prefix = "https://github.com/sponsors/"
  },
  patreon = {
    name = "Patreon",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path d="M22.957 7.21c-.004-3.064-2.391-5.576-5.191-6.482-3.478-1.125-8.064-.962-11.384.604C2.357 3.231 1.093 7.391 1.046 11.54c-.039 3.411.302 12.396 5.369 12.46 3.765.047 4.326-4.804 6.068-7.141 1.24-1.662 2.836-2.132 4.801-2.618 3.376-.836 5.678-3.501 5.673-7.031Z"/></svg>',
    icon_png = "icons/patreon.png",
    icon_unicode = "⚫",
    badge_color = "FF424D",
    badge_logo = "patreon",
    url_prefix = "https://www.patreon.com/"
  },
  ko_fi = {
    name = "Ko-fi",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path d="M11.351 2.715c-2.7 0-4.986.025-6.83.26C2.078 3.285 0 5.154 0 8.61c0 3.506.182 6.13 1.585 8.493 1.584 2.701 4.233 4.182 7.662 4.182h.83c4.209 0 6.494-2.234 7.637-4a9.5 9.5 0 0 0 1.091-2.338C21.792 14.688 24 12.22 24 9.208v-.415c0-3.247-2.13-5.507-5.792-5.87-1.558-.156-2.65-.208-6.857-.208m0 1.947c4.208 0 5.09.052 6.571.182 2.624.311 4.13 1.584 4.13 4v.39c0 2.156-1.792 3.844-3.87 3.844h-.935l-.156.649c-.208 1.013-.597 1.818-1.039 2.546-.909 1.428-2.545 3.064-5.922 3.064h-.805c-2.571 0-4.831-.883-6.078-3.195-1.09-2-1.298-4.155-1.298-7.506 0-2.181.857-3.402 3.012-3.714 1.533-.233 3.559-.26 6.39-.26m6.547 2.287c-.416 0-.65.234-.65.546v2.935c0 .311.234.545.65.545 1.324 0 2.051-.754 2.051-2s-.727-2.026-2.052-2.026m-10.39.182c-1.818 0-3.013 1.48-3.013 3.142 0 1.533.858 2.857 1.949 3.897.727.701 1.87 1.429 2.649 1.896a1.47 1.47 0 0 0 1.507 0c.78-.467 1.922-1.195 2.623-1.896 1.117-1.039 1.974-2.364 1.974-3.897 0-1.662-1.247-3.142-3.039-3.142-1.065 0-1.792.545-2.338 1.298-.493-.753-1.246-1.298-2.312-1.298"/></svg>',
    icon_png = "icons/ko_fi.png",
    icon_unicode = "☕",
    badge_color = "FF5E5B",
    badge_logo = "kofi",
    url_prefix = "https://ko-fi.com/"
  },
  buy_me_a_coffee = {
    name = "Buy Me a Coffee",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path d="M20.216 6.415l-.132-.666c-.119-.598-.388-1.163-1.001-1.379-.197-.069-.42-.098-.57-.241-.152-.143-.196-.366-.231-.572-.065-.378-.125-.756-.192-1.133-.057-.325-.102-.69-.25-.987-.195-.4-.597-.634-.996-.788a5.723 5.723 0 00-.626-.194c-1-.263-2.05-.36-3.077-.416a25.834 25.834 0 00-3.7.062c-.915.083-1.88.184-2.75.5-.318.116-.646.256-.888.501-.297.302-.393.77-.177 1.146.154.267.415.456.692.58.36.162.737.284 1.123.366 1.075.238 2.189.331 3.287.37 1.218.05 2.437.01 3.65-.118.299-.033.598-.073.896-.119.352-.054.578-.513.474-.834-.124-.383-.457-.531-.834-.473-.466.074-.96.108-1.382.146-1.177.08-2.358.082-3.536.006a22.228 22.228 0 01-1.157-.107c-.086-.01-.18-.025-.258-.036-.243-.036-.484-.08-.724-.13-.111-.027-.111-.185 0-.212h.005c.277-.06.557-.108.838-.147h.002c.131-.009.263-.032.394-.048a25.076 25.076 0 013.426-.12c.674.019 1.347.067 2.017.144l.228.031c.267.04.533.088.798.145.392.085.895.113 1.07.542.055.137.08.288.111.431l.319 1.484a.237.237 0 01-.199.284h-.003c-.037.006-.075.01-.112.015a36.704 36.704 0 01-4.743.295 37.059 37.059 0 01-4.699-.304c-.14-.017-.293-.042-.417-.06-.326-.048-.649-.108-.973-.161-.393-.065-.768-.032-1.123.161-.29.16-.527.404-.675.701-.154.316-.199.66-.267 1-.069.34-.176.707-.135 1.056.087.753.613 1.365 1.37 1.502a39.69 39.69 0 0011.343.376.483.483 0 01.535.53l-.071.697-1.018 9.907c-.041.41-.047.832-.125 1.237-.122.637-.553 1.028-1.182 1.171-.577.131-1.165.2-1.756.205-.656.004-1.31-.025-1.966-.022-.699.004-1.556-.06-2.095-.58-.475-.458-.54-1.174-.605-1.793l-.731-7.013-.322-3.094c-.037-.351-.286-.695-.678-.678-.336.015-.718.3-.678.679l.228 2.185.949 9.112c.147 1.344 1.174 2.068 2.446 2.272.742.12 1.503.144 2.257.156.966.016 1.942.053 2.892-.122 1.408-.258 2.465-1.198 2.616-2.657.34-3.332.683-6.663 1.024-9.995l.215-2.087a.484.484 0 01.39-.426c.402-.078.787-.212 1.074-.518.455-.488.546-1.124.385-1.766zm-1.478.772c-.145.137-.363.201-.578.233-2.416.359-4.866.54-7.308.46-1.748-.06-3.477-.254-5.207-.498-.17-.024-.353-.055-.47-.18-.22-.236-.111-.71-.054-.995.052-.26.152-.609.463-.646.484-.057 1.046.148 1.526.22.577.088 1.156.159 1.737.212 2.48.226 5.002.19 7.472-.14.45-.06.899-.13 1.345-.21.399-.072.84-.206 1.08.206.166.281.188.657.162.974a.544.544 0 01-.169.364zm-6.159 3.9c-.862.37-1.84.788-3.109.788a5.884 5.884 0 01-1.569-.217l.877 9.004c.065.78.717 1.38 1.5 1.38 0 0 1.243.065 1.658.065.447 0 1.786-.065 1.786-.065.783 0 1.434-.6 1.499-1.38l.94-9.95a3.996 3.996 0 00-1.322-.238c-.826 0-1.491.284-2.26.613z"/></svg>',
    icon_png = "icons/buy_me_a_coffee.png",
    icon_unicode = "☕",
    badge_color = "FFDD00",
    badge_logo = "buymeacoffee",
    url_prefix = "https://buymeacoffee.com/"
  },
  liberapay = {
    name = "Liberapay",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path d="M2.32 0A2.321 2.321 0 0 0 0 2.32v19.36A2.321 2.321 0 0 0 2.32 24h19.36A2.32 2.32 0 0 0 24 21.68V2.32A2.32 2.32 0 0 0 21.68 0zm9.208 3.98l-2.27 9.405a2.953 2.953 0 0 0-.073.539.853.853 0 0 0 .09.432.7.7 0 0 0 .334.302c.157.077.378.126.661.147l-.49 2.008c-.772 0-1.38-.1-1.82-.3-.441-.203-.757-.477-.947-.826a2.391 2.391 0 0 1-.278-1.2c.005-.452.068-.933.188-1.445l2.074-8.67zm3.9 3.888c.61 0 1.135.092 1.576.277.44.185.802.438 1.085.76.283.32.493.696.629 1.126.136.43.204.89.204 1.379v.001c0 .794-.13 1.52-.392 2.179a5.16 5.16 0 0 1-1.086 1.706 4.84 4.84 0 0 1-1.665 1.118c-.648.267-1.353.4-2.114.4-.37 0-.74-.033-1.11-.098l-.735 2.956H9.403l2.71-11.298c.435-.13.934-.248 1.494-.351a10.045 10.045 0 0 1 1.821-.155zm-.31 2.041a4.67 4.67 0 0 0-.98.098l-1.143 4.752c.185.044.413.065.685.065.425 0 .812-.079 1.16-.237a2.556 2.556 0 0 0 .89-.661c.244-.283.435-.623.571-1.02a4.03 4.03 0 0 0 .204-1.315c0-.468-.104-.865-.31-1.192-.207-.326-.566-.49-1.077-.49z"/></svg>',
    icon_png = "icons/liberapay.png",
    icon_unicode = "💰",
    badge_color = "F6C915",
    badge_logo = "liberapay",
    url_prefix = "https://liberapay.com/"
  },
  open_collective = {
    name = "Open Collective",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 0C5.373 0 0 5.373 0 12s5.373 12 12 12c2.54 0 4.894-.79 6.834-2.135l-3.107-3.109a7.715 7.715 0 1 1 0-13.512l3.107-3.109A11.943 11.943 0 0 0 12 0zm9.865 5.166l-3.109 3.107A7.67 7.67 0 0 1 19.715 12a7.682 7.682 0 0 1-.959 3.727l3.109 3.107A11.943 11.943 0 0 0 24 12c0-2.54-.79-4.894-2.135-6.834z"/></svg>',
    icon_png = "icons/open_collective.png",
    icon_unicode = "○",
    badge_color = "7FADF2",
    badge_logo = "opencollective",
    url_prefix = "https://opencollective.com/"
  },
  tidelift = {
    name = "Tidelift",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 16 16" aria-hidden="true"><path d="M8 1.75l5.5 3v6.5L8 14.25l-5.5-3v-6.5z"/><path d="M2.5 4.75L8 7.75l5.5-3M8 7.75v6.5"/></svg>',
    icon_png = "icons/tidelift.png",
    icon_unicode = "◆",
    badge_color = "F6914D",
    url_prefix = "https://tidelift.com/funding/github/"
  },
  issuehunt = {
    name = "IssueHunt",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 16 16" aria-hidden="true"><circle cx="8" cy="8" r="6"/><circle cx="8" cy="8" r="2.75"/><path d="M8 .75v2.5M8 12.75v2.5M.75 8h2.5M12.75 8h2.5"/></svg>',
    icon_png = "icons/issuehunt.png",
    icon_unicode = "🎯",
    badge_color = "2EBC4F",
    url_prefix = "https://issuehunt.io/r/"
  },
  community_bridge = {
    name = "LFX Mentorship",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path d="M4.8 19.2h9.6V24H0V9.6h4.8v9.6zM0 0v7.2h4.8V4.822h14.4V19.2h-2.4V24H24V0H0z"/></svg>',
    icon_png = "icons/community_bridge.png",
    icon_unicode = "🌉",
    badge_color = "0095D5",
    badge_logo = "linuxfoundation",
    url_prefix = "https://mentorship.lfx.linuxfoundation.org/project/"
  },
  polar = {
    name = "Polar",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16" aria-hidden="true"><path d="M8 .5Q9 7 15.5 8Q9 9 8 15.5Q7 9 .5 8Q7 7 8 .5Z"/></svg>',
    icon_png = "icons/polar.png",
    icon_unicode = "❄️",
    badge_color = "3A98FF",
    url_prefix = "https://polar.sh/"
  },
  thanks_dev = {
    name = "thanks.dev",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16" aria-hidden="true"><path d="M8 14.25S1.5 10.3 1.5 5.9A3.4 3.4 0 0 1 8 4.2a3.4 3.4 0 0 1 6.5 1.7c0 4.4-6.5 8.35-6.5 8.35z"/></svg>',
    icon_png = "icons/thanks_dev.png",
    icon_unicode = "❤️",
    badge_color = "000000",
    url_prefix = "https://thanks.dev/"
  },
  custom = {
    name = "Support",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 16 16" aria-hidden="true"><path d="M6.25 9.75l3.5-3.5"/><path d="M7.4 4.6l1.2-1.2a2.75 2.75 0 0 1 3.9 3.9l-1.2 1.2"/><path d="M8.6 11.4l-1.2 1.2a2.75 2.75 0 0 1-3.9-3.9l1.2-1.2"/></svg>',
    icon_png = "icons/custom.png",
    icon_unicode = "🔗",
    badge_color = "0969DA",
    url_prefix = ""
  }
}

return platforms