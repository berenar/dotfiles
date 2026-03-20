import type { Plugin } from "@opencode-ai/plugin";

export const NotificationPlugin: Plugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  type PermissionAskedEvent = {
    type: "permission.asked";
    properties: {
      permission: string;
      patterns: string[];
    };
  };

  const isKittyFocused = async (): Promise<boolean> => {
    const result =
      await $`osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`.text();
    return result.trim() === "kitty";
  };

  return {
    event: async ({ event }) => {
      const permissionEvent = event as unknown as PermissionAskedEvent;

      if (permissionEvent.type === "permission.asked") {
        const kittyFocused = await isKittyFocused();
        if (!kittyFocused) {
          const permission = permissionEvent.properties.permission;
          const patterns = permissionEvent.properties.patterns.join(", ");
          const script = `display notification ${JSON.stringify(`Permission required: ${permission} (${patterns})`)} with title "opencode" sound name "Pop"`;
          await $`osascript -e ${script}`;
        }
      }

      if (event.type === "session.idle") {
        const kittyFocused = await isKittyFocused();
        if (!kittyFocused) {
          // MacOS sounds can be found on /System/Library/Sounds
          await $`osascript -e 'display notification "Hey! Waiting for you..." with title "opencode" sound name "Pop"'`;
        }
      }
    },
  };
};
