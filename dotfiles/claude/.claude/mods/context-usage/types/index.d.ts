export type UsedTokens = number | null
export type CurrentTime = number | null

declare module 'claude-code' {
  interface PluginState {
    'context-usage': { tokens: UsedTokens; now: CurrentTime }
  }
}
