local platforms = {
  github = {
    name = "GitHub Sponsors",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.012 8.012 0 0 0 16 8c0-4.42-3.58-8-8-8z"/></svg>',
    icon_unicode = "★",
    icon_typst = "★",
    url = function(username) 
      return "https://github.com/sponsors/" .. username 
    end
  },
  patreon = {
    name = "Patreon",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M11.5 0A4.5 4.5 0 1 0 16 4.5 4.506 4.506 0 0 0 11.5 0zM3 16V0h3v16z"/></svg>',
    icon_unicode = "⚫",
    icon_typst = "●",
    url = function(username) 
      return "https://www.patreon.com/" .. username 
    end
  },
  ko_fi = {
    name = "Ko-fi",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M0 2a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V2zm7.5 3A1.5 1.5 0 0 0 6 6.5v3A1.5 1.5 0 0 0 7.5 11h1A1.5 1.5 0 0 0 10 9.5v-3A1.5 1.5 0 0 0 8.5 5h-1z"/></svg>',
    icon_unicode = "☕",
    icon_typst = "☕",
    url = function(username) 
      return "https://ko-fi.com/" .. username 
    end
  },
  buy_me_a_coffee = {
    name = "Buy Me a Coffee",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M0 2a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V2zm7.5 3A1.5 1.5 0 0 0 6 6.5v3A1.5 1.5 0 0 0 7.5 11h1A1.5 1.5 0 0 0 10 9.5v-3A1.5 1.5 0 0 0 8.5 5h-1z"/></svg>',
    icon_unicode = "☕",
    icon_typst = "☕",
    url = function(username) 
      return "https://buymeacoffee.com/" .. username 
    end
  },
  liberapay = {
    name = "Liberapay",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M3 3h10v10H3z"/></svg>',
    icon_unicode = "💰",
    icon_typst = "💰",
    url = function(username) 
      return "https://liberapay.com/" .. username 
    end
  },
  open_collective = {
    name = "Open Collective",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><circle cx="8" cy="8" r="7" stroke="currentColor" stroke-width="2" fill="none"/></svg>',
    icon_unicode = "○",
    icon_typst = "○",
    url = function(username) 
      return "https://opencollective.com/" .. username 
    end
  },
  tidelift = {
    name = "Tidelift",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M8 0l8 8-8 8-8-8z"/></svg>',
    icon_unicode = "◆",
    icon_typst = "◆",
    url = function(package_name) 
      return "https://tidelift.com/funding/github/" .. package_name 
    end
  },
  issuehunt = {
    name = "IssueHunt",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M8 0a8 8 0 1 0 0 16A8 8 0 0 0 8 0zm0 14a6 6 0 1 1 0-12 6 6 0 0 1 0 12z"/></svg>',
    icon_unicode = "🎯",
    icon_typst = "🎯",
    url = function(username) 
      return "https://issuehunt.io/r/" .. username 
    end
  },
  community_bridge = {
    name = "LFX Mentorship",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M8 0L0 8l8 8 8-8z"/></svg>',
    icon_unicode = "🌉",
    icon_typst = "🌉",
    url = function(project) 
      return "https://mentorship.lfx.linuxfoundation.org/project/" .. project 
    end
  },
  polar = {
    name = "Polar",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M8 0L0 8l8 8 8-8z"/></svg>',
    icon_unicode = "❄️",
    icon_typst = "❄️",
    url = function(username) 
      return "https://polar.sh/" .. username 
    end
  },
  thanks_dev = {
    name = "thanks.dev",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M8 2.748l-.717-.737C5.6.281 2.514.878 1.4 3.053c-.523 1.023-.641 2.5.314 4.385.92 1.815 2.834 3.989 6.286 6.357 3.452-2.368 5.365-4.542 6.286-6.357.955-1.885.838-3.362.314-4.385C13.486.878 10.4.28 8.717 2.01L8 2.748z"/></svg>',
    icon_unicode = "❤️",
    icon_typst = "❤",
    url = function(username) 
      return "https://thanks.dev/" .. username 
    end
  },
  custom = {
    name = "Support",
    icon_html = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M8 0a8 8 0 1 0 0 16A8 8 0 0 0 8 0zm0 14a6 6 0 1 1 0-12 6 6 0 0 1 0 12z"/></svg>',
    icon_unicode = "🔗",
    icon_typst = "🔗",
    url = function(url) 
      return url 
    end
  }
}

return platforms