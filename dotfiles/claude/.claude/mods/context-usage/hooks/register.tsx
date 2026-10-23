import { atom, read, update } from 'claude-code'
import type { Register, SessionRateLimit } from 'claude-code'

const WARNING_PERCENT = 50
const RATE_LIMIT_WARNING_PERCENT = 80
const MODES_SEPARATOR = ' & '
const ITEMS_SEPARATOR = ' · '
const CONFIG_DIR_PREFIX = '.claude-'
const SHOWN_RATE_LIMIT_KINDS = ['five_hour', 'seven_day'] as const
const CLOCK_TICK_MS = 60_000
const MS_PER_MINUTE = 60_000
const MINUTES_PER_HOUR = 60
const MINUTES_PER_DAY = 1440

const usedTokens = atom({ plugin: 'context-usage', key: 'tokens' } as const, null)
const currentTime = atom({ plugin: 'context-usage', key: 'now' } as const, null)

const TOKEN_UNITS = [
  { size: 1_000_000, suffix: 'M' },
  { size: 1_000, suffix: 'k' },
] as const

const DEFAULT_ACCOUNT_COLOR = 'cyan'
const ACCOUNT_COLORS: Record<string, string> = {
  clbrt: '#B083F0',
  mvst: '#8B5A2B',
}

const RATE_LIMIT_LABELS: Record<string, string> = {
  five_hour: '5h',
  seven_day: '7d',
}

const formatTokens = (tokens: number): string => {
  const unit = TOKEN_UNITS.find(({ size }) => tokens >= size)
  if (unit === undefined) return `${tokens}`
  const scaled = Math.ceil(tokens / unit.size)
  return `${scaled}${unit.suffix}`
}

const formatDuration = (milliseconds: number): string => {
  const totalMinutes = Math.max(0, Math.floor(milliseconds / MS_PER_MINUTE))
  const days = Math.floor(totalMinutes / MINUTES_PER_DAY)
  const hours = Math.floor((totalMinutes % MINUTES_PER_DAY) / MINUTES_PER_HOUR)
  const minutes = totalMinutes % MINUTES_PER_HOUR
  if (days > 0) return `${days}d${hours}h`
  if (hours > 0) return `${hours}h${minutes}m`
  return `${minutes}m`
}

const getAccountName = (configDir: string | undefined): string | null => {
  if (configDir === undefined) return null
  const directoryName = configDir.replace(/\/+$/, '').split('/').pop() ?? ''
  if (!directoryName.startsWith(CONFIG_DIR_PREFIX)) return null
  return directoryName.slice(CONFIG_DIR_PREFIX.length)
}

const findShownRateLimits = (rateLimits: readonly SessionRateLimit[]): SessionRateLimit[] =>
  SHOWN_RATE_LIMIT_KINDS.map(shownKind => rateLimits.find(({ kind }) => kind === shownKind)).filter(
    (rateLimit): rateLimit is SessionRateLimit => rateLimit !== undefined,
  )

const formatRateLimit = (rateLimit: SessionRateLimit, now: number): string => {
  const windowLabel = RATE_LIMIT_LABELS[rateLimit.kind] ?? rateLimit.kind
  const usage = `${Math.round(rateLimit.percentUsed)}% used of ${windowLabel}`
  if (rateLimit.resetsAt === undefined) return usage
  const timeUntilReset = Date.parse(rateLimit.resetsAt) - now
  return `${usage}${ITEMS_SEPARATOR}reset in ${formatDuration(timeUntilReset)}`
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const { context } = await $.session.usage()
    await update($, usedTokens, () => context.tokens ?? null)
    const startTime = await $.clock.now()
    await update($, currentTime, () => startTime)
    $.clock.every(CLOCK_TICK_MS, async () => {
      const tickTime = await $.clock.now()
      await update($, currentTime, () => tickTime)
    })
    return next(e)
  })

  on('turn.start', async ($, e, next) => {
    const { context } = await $.session.usage()
    await update($, usedTokens, () => context.tokens ?? null)
    return next(e)
  })

  on('session.measure', async ($, e, next) => {
    await update($, usedTokens, () => e.context.tokens ?? null)
    return next(e)
  })

  on('ui.render', { component: 'SessionMode' }, async ($, e, next) => {
    const tokens = await read($, usedTokens)
    if (tokens === null) return next(e)

    const { context, rateLimits } = await $.session.usage()
    const now = (await read($, currentTime)) ?? (await $.clock.now())
    const accountName = getAccountName(await $.env.get('CLAUDE_CONFIG_DIR'))
    const shownRateLimits = findShownRateLimits(rateLimits)

    const percent = Math.round((tokens / context.window) * 100)
    const contextLabel = `${formatTokens(tokens)}/${formatTokens(context.window)}`
    const isContextAboveWarning = percent > WARNING_PERCENT
    const modesPrefix = e.props.modes.length > 0 ? `${e.props.modes.join(MODES_SEPARATOR)}${MODES_SEPARATOR}` : ''
    const { Box, Text } = $.ui.resolve(e)

    return (
      <Box>
        {accountName !== null && <Text color={ACCOUNT_COLORS[accountName] ?? DEFAULT_ACCOUNT_COLOR}>{accountName}</Text>}
        {accountName !== null && <Text dimColor>{ITEMS_SEPARATOR}</Text>}
        <Text dimColor>{modesPrefix}</Text>
        {isContextAboveWarning ? <Text color="yellow">{contextLabel}</Text> : <Text dimColor>{contextLabel}</Text>}
        {shownRateLimits.map(rateLimit => (
          <Box key={rateLimit.kind}>
            <Text dimColor>{ITEMS_SEPARATOR}</Text>
            {rateLimit.percentUsed > RATE_LIMIT_WARNING_PERCENT ? (
              <Text color="yellow">{formatRateLimit(rateLimit, now)}</Text>
            ) : (
              <Text dimColor>{formatRateLimit(rateLimit, now)}</Text>
            )}
          </Box>
        ))}
      </Box>
    )
  })
}
