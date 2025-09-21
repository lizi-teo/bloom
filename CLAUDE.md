# Figma MCP Server Commands

## Available Commands

### Get Code
- **Command**: `figma_get_code`
- **Purpose**: Extract code snippets from Figma designs
- **Parameters**:
  - `file_key`: The Figma file ID
  - `node_id`: Specific node/component ID (optional)
  - `language`: Target language (css, swift, android, etc.)
- **Returns**: Generated code for the specified design element

### Get Variables
- **Command**: `figma_get_variables`
- **Purpose**: Retrieve design variables/tokens from Figma
- **Parameters**:
  - `file_key`: The Figma file ID
  - `variable_collection_id`: Specific collection ID (optional)
- **Returns**: Design tokens including colors, spacing, typography, etc.

### Get Design
- **Command**: `figma_get_design`
- **Purpose**: Fetch design information and properties
- **Parameters**:
  - `file_key`: The Figma file ID
  - `node_id`: Specific node/component ID (optional)
  - `depth`: How deep to traverse the node tree
- **Returns**: Design structure, properties, and metadata

## Common Usage Examples

### Extracting CSS from a component
```
figma_get_code --file_key "ABC123" --node_id "1:234" --language "css"
```

### Getting all design tokens
```
figma_get_variables --file_key "ABC123"
```

### Fetching full design structure
```
figma_get_design --file_key "ABC123" --depth 3
```

## Notes
- File keys can be found in Figma URLs: figma.com/file/{FILE_KEY}/...
- Node IDs are available in Figma's developer mode
- Ensure Figma API token is configured before using these commands

## Documentation

### Figma to Flutter Guides (#ff)

**Focused guides for efficient development:**

- **#theme** - `.docs/figma-to-flutter/theme-mapping.md` - **CRITICAL**: Figma → Flutter theme conversion, never hardcode values
- **#atoms** - `.docs/figma-to-flutter/atoms-guide.md` - Creating small components with theme compliance
- **#organisms** - `.docs/figma-to-flutter/organisms-guide.md` - Complex components with mobile-first responsive design
- **#pages** - `.docs/figma-to-flutter/pages-guide.md` - Complete page templates with copy-paste examples
- **#mobile** - `.docs/figma-to-flutter/mobile-requirements.md` - Essential SafeArea, scrolling, and mobile UX patterns
- **#rtext** - `.docs/figma-to-flutter/responsive-typography.md` - Material Design 3 responsive text sizing for mobile vs desktop
- **#buttons** - `.docs/figma-to-flutter/button-sizing-guide.md` - Material Design 3 button sizing standards for mobile vs desktop responsiveness
- **#spacing** - `.docs/figma-to-flutter/responsive-padding-guide.md` - Contextual spacing system, page edge padding, and responsive spacing patterns
- **#checklist** - `.docs/figma-to-flutter/quick-checklist.md` - Validation steps before completion
- **#review** - `.docs/figma-to-flutter/review-code.md` - Comprehensive Flutter code review instructions for frontend refactoring

Use `#ff` to reference all guides, or use specific shortcuts like `#theme` for targeted guidance.

### Figma Links Reference (#fp)
For quick reference to specific Figma design pages and components, see `.docs/figma-links.md`. This contains:
- Session management components (Create Session Form, Session List)
- Feedback system components (Feedback Templates)
- Direct Figma links and node IDs for each component

Use `#fl` as a shortcut to reference the Figma links documentation in prompts.

## Shortcuts

### #fig - Complete Figma Analysis
Use `#fig` in prompts to trigger a comprehensive Figma analysis using all available MCP server commands:
- `get_variable_defs` - Extract design variables/tokens
- `get_code` - Generate code for components  
- `get_image` - Get visual representation

This shortcut tells Claude Code to run all relevant Figma MCP commands for the current selection or specified node.

## Flutter Development Commands

### #flutter - Run Flutter in Browser
Use `#flutter` as a shortcut to run the Flutter application in Chrome browser:
```bash
flutter run -d chrome --dart-define-from-file=.config/config.development.json
```

This is the primary development command for running the Bloom app in web/browser mode with environment variables loaded using Chrome browser.

## Testing Commands

### #test - Run Flutter Tests
Use `#test` as a shortcut to run Flutter tests with development configuration:
```bash
flutter test --platform chrome --dart-define-from-file=.config/config.development.json
```

This runs tests on Chrome platform (needed for `dart:html` compatibility) with development environment variables (including `APP_BASE_URL: http://localhost:62299`) so that shareable URLs and other web-dependent features work correctly during testing.

Alternative for VM-only tests (without web dependencies):
```bash
flutter test --dart-define-from-file=.config/config.development.json
```