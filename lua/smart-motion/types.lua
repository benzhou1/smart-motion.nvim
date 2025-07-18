---@meta

---@class SmartMotionPlugin
---@field setup fun(user_config: SmartMotionConfig | nil)
---@field register_motion fun(name: string, motion: SmartMotionMotionEntry, opts?: table)
---@field register_many_motions fun(tbl: table<string, SmartMotionMotionEntry>, opts?: { override?: boolean })
---@field map_motion fun(name: string, motion_opts: SmartMotionMotionEntry, opts?: table): nil
---@field collectors { register: fun(name: string, mod: SmartMotionCollectorModuleEntry), register_many: fun(tbl: table<string, SmartMotionCollectorModule>, opts?: { override?: boolean }) }
---@field extractors { register: fun(name: string, mod: SmartMotionExtractorModuleEntry), register_many: fun(tbl: table<string, SmartMotionExtractorModule>, opts?: { override?: boolean }) }
---@field filters { register: fun(name: string, mod: SmartMotionFilterModuleEntry), register_many: fun(tbl: table<string, SmartMotionFilterModule>, opts?: { override?: boolean }) }
---@field visualizers { register: fun(name: string, mod: SmartMotionVisualizerModuleEntry), register_many: fun(tbl: table<string, SmartMotionVisualizerModule>, opts?: { override?: boolean }) }
---@field actions { register: fun(name: string, mod: SmartMotionActionModuleEntry), register_many: fun(tbl: table<string, SmartMotionActionModule>, opts?: { override?: boolean }) }
---@field pipeline_wrappers { register: fun(name: string, mod: SmartMotionPipelineWrapperModuleEntry), register_many: fun(tbl: table<string, SmartMotionPipelineWrapperModule>, opts?: { override?: boolean }) }
---@field consts table  -- optional: you could also type consts more specifically later

---@class SmartMotionConfig
---@field keys string[]
---@field highlight table<string, string | table>
---@field presets SmartMotionPresets
---@field flow_state_timeout_ms number
---@field disable_dim_background boolean

---@class SmartMotionPresets
---@field words? true | SmartMotionPresetKey.Words[]
---@field lines? true | SmartMotionPresetKey.Lines[]
---@field search? true | SmartMotionPresetKey.Search[]
---@field delete? true | SmartMotionPresetKey.Delete[]
---@field yank? true | SmartMotionPresetKey.Yank[]
---@field change? true | SmartMotionPresetKey.Change[]
---@field [string] boolean | string[]

---@alias SmartMotionPresetKey.Words "w" | "b" | "e" | "ge"
---@alias SmartMotionPresetKey.Lines "j" | "k"
---@alias SmartMotionPresetKey.Search "s" | "S" | "f" | "F"
---@alias SmartMotionPresetKey.Delete "d" | "dt" | "dT" | "rdw" | "rdl"
---@alias SmartMotionPresetKey.Yank "y" | "yt" | "yT" | "ryw" | "ryl"
---@alias SmartMotionPresetKey.Change "c" | "ct" | "cT"

---@class SmartMotionPresetsModule
---@field words fun(exclude?: SmartMotionPresetKey.Words[])
---@field lines fun(exclude?: SmartMotionPresetKey.Lines[])
---@field search fun(exclude?: SmartMotionPresetKey.Search[])
---@field delete fun(exclude?: SmartMotionPresetKey.Delete[])
---@field yank fun(exclude?: SmartMotionPresetKey.Yank[])
---@field change fun(exclude?: SmartMotionPresetKey.Change[])
---@field _register fun(motions_list: table<string, SmartMotionModule>, exclude?: string[])

---@class SmartMotionContext
---@field bufnr integer
---@field winid integer
---@field cursor_line integer
---@field cursor_col integer
---@field last_line integer

--- @class SmartMotionMotionState
--- @field total_keys integer
--- @field max_lines integer
--- @field max_labels integer
--- @field direction Direction
--- @field hint_position HintPosition
--- @field target_type TargetType
--- @field ignore_whitespace boolean
--- @field jump_target_count integer
--- @field jump_targets JumpTarget[]  -- Replace `any` with a concrete `JumpTarget` type later
--- @field ignore_target? fun(target: JumpTarget, label: string): boolean Allows filtering of targets without ordering of labels changing
--- @field selected_jump_target? JumpTarget
--- @field selected_jump_char? string
--- @field hint_labels string[]  -- Possibly just strings or label metadata?
--- @field assigned_hint_labels table<string, HintEntry>
--- @field single_label_count integer
--- @field double_label_count integer
--- @field sacrificed_keys_count integer
--- @field selection_mode SelectionMode
--- @field selection_first_char? string
--- @field auto_select_target? boolean
--- @field virt_text_pos? "eol" | "overlay" | "right_align" | "inline"
--- @field search_text? string
--- @field last_search_text? string | nil
--- @field is_searching_mode? boolean
--- @field exclude_target? boolean -- Used to exclude hinted character and act like "until"
--- @field num_of_char? number
--- @field should_show_prefix? boolean
--- @field allow_quick_action? boolean -- Used to control if we should run action on target under cursor
--- @field sort_by? "sort_weight"
--- @field sort_descending? boolean
--- @field timeout_after_input? boolean
--- @field word_pattern? string
--- @field paste_mode? 'before' | 'after'
--- @field keys? fun(motion_state: SmartMotionMotionState): string[]
--- @field motion SmartMotionMotionEntry

---@class SmartMotionTarget
---@field bufnr integer
---@field winid integer
---@field row integer
---@field col integer
---@field text string
---@field start_pos { row: integer, col: integer }
---@field end_pos { row: integer, col: integer }
---@field type string
---@field metadata? table

---@class SmartMotionHintEntry
---@field jump_target? SmartMotionTarget
---@field is_single_prefix? boolean
---@field is_double_prefix? boolean

---@generic T
---@class SmartMotionModuleEntry<T>
---@field run T
---@field keys? string[]
---@field name? string
---@field state? SmartMotionMotionState
---@field metadata? { label?: string, description?: string }

---@alias SmartMotionCollectorModuleEntry SmartMotionModuleEntry<fun(): thread>

---@alias SmartMotionExtractorModuleEntry SmartMotionModuleEntry<fun(generator: thread): thread>

---@alias SmartMotionActionModuleEntry SmartMotionModuleEntry<fun(
  ctx: SmartSmartMotionContext,
  cfg: SmartMotionConfig,
  state: SmartMotionMotionState,
): nil>

---@alias SmartMotionVisualizerModuleEntry SmartMotionModuleEntry<fun(
  ctx: SmartSmartMotionContext,
  cfg: SmartMotionConfig,
  state: SmartMotionMotionState
): nil>

---@alias SmartMotionFilterModuleEntry SmartMotionModuleEntry<fun(
  ctx: SmartSmartMotionContext,
  cfg: SmartMotionConfig,
  state: SmartMotionMotionState
): nil>

---@alias SmartMotionModifierModuleEntry SmartMotionModuleEntry<fun(
  ctx: SmartSmartMotionContext,
  cfg: SmartMotionConfig,
  state: SmartMotionMotionState
): nil>

---@alias SmartMotionPipelineWrapperModuleEntry SmartMotionModuleEntry<fun(
  pipeline: fun(
    ctx: SmartSmartMotionContext,
    cfg: SmartMotionConfig,
    state: SmartMotionMotionState,
  ): nil,
  ctx: SmartSmartMotionContext,
  cfg: SmartMotionConfig,
  state: SmartMotionMotionState,
  action: SmartMotionActionModule
): boolean?>

---@class SmartMotionMotionEntry
---@field trigger_key? string
---@field infer? boolean
---@field pipeline { collector: string, extractor: string, visualizer: string, filter?: string }
---@field pipeline_wrapper? string
---@field action string
---@field state? SmartMotionMotionState
---@field map? boolean
---@field modes? string[]
---@field name? string
---@field metadata? { label?: string, description?: string }

---@alias SmartMotionRegistryType
  | "collectors"
  | "extractors"
  | "filters"
  | "visualizers"
  | "actions"
  | "pipeline_wrappers"
  | "motions"

---@generic T
---@class SmartMotionRegistry<T>
---@field by_key table<string, T>
---@field by_name table<string, T>
---@field module_type string
---@field register fun(name: string, entry: T): nil
---@field register_many fun(entries: table<string, T>, opts?: { override?: boolean }): nil
---@field get_by_key fun(key: string): T|nil
---@field get_by_name fun(name: string): T|nil
---@field _validate_module_entry fun(name: string, entry: T): boolean

---@class SmartMotionRegistryMap
---@field collectors SmartMotionRegistry<SmartMotionCollectorModuleEntry>
---@field extractors SmartMotionRegistry<SmartMotionExtractorModuleEntry>
---@field filters SmartMotionRegistry<SmartMotionFilterModuleEntry>
---@field modifiers SmartMotionRegistry<SmartMotionModifierModuleEntry>
---@field visualizers SmartMotionRegistry<SmartMotionVisualizerModuleEntry>
---@field actions SmartMotionRegistry<SmartMotionActionModuleEntry>
---@field pipeline_wrappers SmartMotionRegistry<SmartMotionPipelineWrapperModuleEntry>
---@field motions SmartMotionMotionRegistry

---@class SmartMotionRegistryManager
---@field registries? SmartMotionRegistryMap
---@field init fun(self: SmartMotionRegistryManager, registry_table: SmartMotionRegistryMap)
---@field get fun(self: SmartMotionRegistryManager): SmartMotionRegistryMap

--- @class SmartMotionMotionRegistry : SmartMotionRegistry<SmartMotionMotionEntry>
--- @field _validate_motion_entry fun(name: string, motion: SmartMotionMotionEntry): boolean
--- @field register_motion fun(name: string, motion: SmartMotionMotionEntry, opts?: table): nil
--- @field register_many_motions fun(tbl: table<string, SmartMotionMotionEntry>, opts?: { override?: boolean }): nil
--- @field map_motion fun(name: string, motion_opts: SmartMotionMotionEntry, opts): nil
