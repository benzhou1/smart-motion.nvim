```
   _____                      __  __  ___      __  _                          _         
  / ___/____ ___  ____ ______/ /_/  |/  /___  / /_(_)___  ____    ____ _   __(_)___ ___ 
  \__ \/ __ `__ \/ __ `/ ___/ __/ /|_/ / __ \/ __/ / __ \/ __ \  / __ \ | / / / __ `__ \
 ___/ / / / / / / /_/ / /  / /_/ /  / / /_/ / /_/ / /_/ / / / / / / / / |/ / / / / / / /
/____/_/ /_/ /_/\__,_/_/   \__/_/  /_/\____/\__/_/\____/_/ /_(_)_/ /_/|___/_/_/ /_/ /_/ 
                                                                                        
```

⚡ SmartMotion.nvim - Home-row powered smart motions for Neovim ⚡

---

## 📖 What is SmartMotion?

`SmartMotion.nvim` is a next-generation motion plugin for Neovim that brings **intuitive, home-row driven navigation** to your code. Forget counting words or characters — SmartMotion instantly highlights jump targets **with dynamic, in-place labels**, allowing you to navigate faster and more naturally.

---

## 🚀 Why SmartMotion? (What Makes Us Different)

SmartMotion takes the **best ideas from plugins like Hop.nvim and EasyMotion**, and layers on:

✅ **Smart Label Generation:** Dynamically chooses between single-character and double-character labels based on target density. This means:
- Short distances = simple, fast single keys.
- Long distances = seamless double-character hints (no collisions).

✅ **Dynamic Highlight Feedback:** As you select the first character in a double hint, SmartMotion **dims the first character and highlights the second**, keeping focus intuitive.

✅ **Zero Default Mappings:** You control how and when SmartMotion activates — no keybinding conflicts.

✅ **Future-Proof:** SmartMotion’s architecture is **motion-type agnostic**, ready for expansions into character motions (`f`, `t`), line motions (`j`, `k`), and even **operator-pending motions** (`d`, `c`, `y`).

---

## 📚 Table of Contents

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

- ⚡ **Home-row driven jump hints**
- 🔗 **Single and double character label support**
- 🎨 **Customizable highlights for hints, dimming, and progressive selection feedback**
- 🌍 **Multi-line support**
- ❌ **Zero mappings added by default (you’re in control)**
- ✅ **Works forward and backward (`w`, `b`, `e`, `ge`)**
- 🧠 **Smart label generation scales automatically with density**
- 📦 **No dependencies - pure Lua**

---

## 💻 Installation

### lazy.nvim
```lua
{
    "your-username/smart-motion.nvim",
    config = function()
        require("smart-motion").setup()
    end
}
