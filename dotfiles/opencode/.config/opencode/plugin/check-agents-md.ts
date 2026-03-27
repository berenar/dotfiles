import { promises as fs } from "fs";
import { join } from "path";
import type { Plugin } from "@opencode-ai/plugin";

const AGENTS_FILENAME = "AGENTS.md";

export const CheckAgentsMdPlugin: Plugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  return {
    event: async ({ event }) => {
      if (event.type !== "session.created" || event.properties.info.parentID) {
        // Only notify on root sessions, ignore subagents
        return;
      }

      try {
        const agentsMdPath = join(directory, AGENTS_FILENAME);
        await fs.access(agentsMdPath);
      } catch {
        // MacOS sounds can be found on /System/Library/Sounds
        await $`osascript -e 'display notification "Run /init to get started" with title "opencode" subtitle "No ${AGENTS_FILENAME} file found" sound name "Sosumi"'`;
      }
    },
  };
};
