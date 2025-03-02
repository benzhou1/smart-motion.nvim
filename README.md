```
   _____                      __  __  ___      __  _                          _         
  / ___/____ ___  ____ ______/ /_/  |/  /___  / /_(_)___  ____    ____ _   __(_)___ ___ 
  \__ \/ __ `__ \/ __ `/ ___/ __/ /|_/ / __ \/ __/ / __ \/ __ \  / __ \ | / / / __ `__ \
 ___/ / / / / / / /_/ / /  / /_/ /  / / /_/ / /_/ / /_/ / / / / / / / / |/ / / / / / / /
/____/_/ /_/ /_/\__,_/_/   \__/_/  /_/\____/\__/_/\____/_/ /_(_)_/ /_/|___/_/_/ /_/ /_/ 
                                                                                        
```

# SmartMotion.nvim - Home-row powered smart motions for Neovim

## 📖 What is SmartMotion?

`SmartMotion.nvim` is a next-generation motion plugin for Neovim that brings **intuitive, home-row driven navigation** to your code. Forget counting words or characters — SmartMotion instantly highlights jump targets **with dynamic, in-place labels**, allowing you to navigate faster and more naturally.

---

## 🚀 Why SmartMotion? (What Makes Us Different)

SmartMotion takes the **best ideas from plugins like Hop.nvim and EasyMotion**, and layers on:

- 🔦 **Smart Label Generation:** Dynamically chooses between single-character and double-character labels based on target density.
- 🔦 **Dynamic Highlight Feedback:** After selecting the first character in a double hint, SmartMotion dims the first and highlights the second.
- 🛠️ **Zero Default Mappings:** You control how and when SmartMotion activates — no keybinding conflicts.
- 🔄 **Expandable Architecture:** Built to support future motions like `f`, `t`, paragraph, line, and operator motions.

---

## 📃 Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Exposed Methods](#exposed-methods)
- [Example Mappings](#example-mappings)
- [Roadmap](#roadmap)
- [Similar Plugins](#similar-plugins)
- [Other Plugins By Me](#other-plugins-by-me)
- [Shameless Plug](#shameless-plug)

---

## ✨ Features

- Home-row powered jump hints
- Single & double character label support
- Dynamic feedback highlighting
- Multi-line support
- No default mappings — you are in control
- Works with `w`, `b`, `e`, `ge` out of the box
- Smart label generation
- No dependencies — pure Lua

---

## 💳 Installation

### lazy.nvim

```lua
{
    "FluxxField/smart-motion.nvim",
    config = function()
        require("smart-motion").setup()
    end
}
```

---

## 🛠️ Configuration

```lua
require("smart-motion").setup({
    keys = "fjdksleirughtynm",
    highlight = {
        dim = "SmartMotionDim",
        hint = "SmartMotionHint",
        first_char = "SmartMotionFirstChar",
        second_char = "SmartMotionSecondChar",
        first_char_dim = "SmartMotionFirstCharDim",
    },
    multi_line = true,
    mappings = {
        n = {},
        v = {}
    },
})
```

---

## 🔹 Important Callout: No Default Mappings

SmartMotion does not register any mappings by default. You must define your own. Example:

```lua
vim.keymap.set("n", "w", function() require("smart-motion").hint_words("after_cursor", "start") end)
vim.keymap.set("n", "b", function() require("smart-motion").hint_words("before_cursor", "start") end)
vim.keymap.set("n", "e", function() require("smart-motion").hint_words("after_cursor", "end") end)
vim.keymap.set("n", "ge", function() require("smart-motion").hint_words("before_cursor", "end") end)
```

---

## 🎮 Exposed Methods

| Method                            | Description                      |
| --------------------------------- | -------------------------------- |
| `hint_words(direction, position)` | Word jump motion                 |
| `hint_characters()`               | (Future) Character search motion |
| `hint_lines()`                    | (Future) Line jump motion        |

---

## 🕹️ Example Mappings

```lua
vim.keymap.set("n", "w", function() require("smart-motion").hint_words("after_cursor", "start") end)
vim.keymap.set("n", "b", function() require("smart-motion").hint_words("before_cursor", "start") end)
vim.keymap.set("n", "e", function() require("smart-motion").hint_words("after_cursor", "end") end)
vim.keymap.set("n", "ge", function() require("smart-motion").hint_words("before_cursor", "end") end)
```

---

## 🌆 Roadmap

- Character motions (`f`, `t`, `F`, `T`)
- Operator support (`d`, `c`, `y`)
- Configurable timeout between double-char hints
- Paragraph & block motions
- Advanced label tuning

---

## 🔗 Similar Plugins

| Plugin                                            | Notes              |
| ------------------------------------------------- | ------------------ |
| [Hop.nvim](https://github.com/phaazon/hop.nvim)   | Big inspiration    |
| [leap.nvim](https://github.com/ggandor/leap.nvim) | 2-char quick jumps |

---

## 🛠️ Other Plugins By Me

| Plugin                                                                   | Description                   |
| ------------------------------------------------------------------------ | ----------------------------- |
| [bionic-reading.nvim](https://github.com/FluxxField/bionic-reading.nvim) | Syllable-based bionic reading |

---

## 💼 Shameless Plug

I also build custom websites for businesses, startups, and personal brands! If you want:

- Stunning design & performance
- Modern, SEO-optimized tech
- Built using Next.js, Astro, or tailored to your stack

Check out:

- [Cornerstone Homes](https://www.cornerstonehomesok.com)
- [SLP Custom Built](https://www.slpcustombuilt.com)

📧 Contact me at: [keenanjj13@protonmail.com](mailto:keenanjj13@protonmail.com)

---

## 🏆 License

MIT

---

## ✨ Author

Built with ❤️ by [FluxxField](https://github.com/FluxxField)
