export type UsedTokens = number | null

declare module 'claude-code' {
  interface PluginState {
    'context-usage': { tokens: UsedTokens }
  }
}
