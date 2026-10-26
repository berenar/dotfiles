export type UsedTokens = number | null
export type CurrentTime = number | null
export type CurrentEffort = string | null

declare module 'claude-code' {
  interface PluginState {
    'context-usage': { tokens: UsedTokens; now: CurrentTime; effort: CurrentEffort }
  }
}
